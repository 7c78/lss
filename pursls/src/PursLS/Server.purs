module PursLS.Server where

import Prelude

import Control.Monad.Error.Class (throwError)
import Data.Maybe (Maybe(..), maybe, isNothing)
import Data.Either (Either(..), hush)
import Data.Int as Int
import Data.Array.Safe as Array
import Data.Array.NonEmpty ((!!))
import Data.String.Safe as String
import Data.String.Pattern (Pattern(..))
import Data.String.Regex (regex, match) as Regex
import Data.String.Regex.Flags (noFlags) as Flags
import Data.MMap as MMap
import Data.List (List(..), (:))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Random as Random
import Effect.Exception (Error, error)
import Effect.Ref as Ref
import Promise as JS
import Promise.Aff as JS.Promise
import Node.Path (FilePath)
import Node.Process as Process
import Node.ChildProcess as ChildProcess
import Node.ChildProcess.Types as Exit
import Node.Errors.SystemError as SysError
import Node.EventEmitter (on_, once_)
import Node.Stream as Stream
import Node.Buffer as Buffer
import Node.Encoding as Encoding
import Node.Which (which)
import PursIDE.Server as PursIDE
import PursIDE.Command as Command
import LSP.Types as LSP
import LSP.Connection as LSP.Connection
import LSP.TextDocuments as LSP.TextDocuments
import LSP.ClientRequest as LSP.ClientRequest
import LSP.ClientNotification as LSP.ClientNotification
import LSP.ServerRequest as LSP.ServerRequest
import TaskQueue as TaskQueue
import PursLS.App (App, runApp)
import PursLS.App.Env (Env(..))
import PursLS.App.Log.Internal as Log
import PursLS.Handler.TextDocument.Hover (hover) as TextDocument
import PursLS.Handler.TextDocument.Definition (definition) as TextDocument
import PursLS.Handler.TextDocument.References (references) as TextDocument
import PursLS.Handler.TextDocument.DidSave (didSave) as TextDocument

type ServerOptions =
    { logfile  :: FilePath
    , loglevel :: Log.LogLevel
    }

start :: ServerOptions -> Effect Unit
start { logfile, loglevel } = do
    log <- Log.makeFileLog logfile
    workspace <- Process.cwd
    dependencies <- MMap.new
    taskQueue <- TaskQueue.new

    lspConn <- LSP.Connection.new
    documents <- LSP.TextDocuments.new lspConn

    spago <- Array.head <$> which "spago"
    mExistingPort <- findExistingPursIDEPort workspace
    idePort <- maybe (Random.randomInt 15000 16000) pure mExistingPort

    let env = Env { log
                  , loglevel
                  , workspace
                  , lspConn
                  , documents
                  , idePort
                  , dependencies
                  , taskQueue
                  , spago
                  }

    if isNothing mExistingPort then
        Aff.launchAff_ do
            buildProject env
            liftEffect do
                globs <- getSourcePaths spago workspace
                PursIDE.start (Aff.launchAff_ <<< killServer env)
                    { directory: workspace
                    , port: idePort
                    , globs
                    }
                log Log.Debug $ "Purs IDE started at port " <> show idePort

                handlers env
    else
        handlers env

findExistingPursIDEPort :: String -> Effect (Maybe Int)
findExistingPursIDEPort workspace = do
    let ps =  "pgrep -fa 'purs ide server.*--directory " <> workspace <> "'"
              -- finds the process matching the workspace and prints the entire command line.
           <> " | sed -n 's/.*--port \\([0-9]*\\).*/\\1/p'"
              -- looks for --port followed by digits, captures those digits, and prints only that captured group.
    buf <- ChildProcess.execSync ps
    output <- Buffer.toString Encoding.UTF8 buf
    pure $ Int.fromString (String.trim output)

buildProject :: Env App -> Aff Unit
buildProject (Env { spago, workspace, lspConn }) = do
    buildP <- liftEffect $ ChildProcess.spawn' spago ["build"]
                    (_ { cwd = Just workspace
                       })

    Aff.makeAff \cb -> Aff.nonCanceler <$ do
        outputRef <- Ref.new Nil

        ChildProcess.stderr buildP # on_ Stream.dataH \buf -> do
            text <- Buffer.toString Encoding.UTF8 buf
            case compilingStatus text of
                Nothing ->
                    Ref.modify_ (text : _) outputRef
                Just { current, total } ->
                    LSP.ServerRequest.window_showInfoMessage lspConn $
                        "Compiling [" <> current <> "/" <> total <> "]"

        buildP # once_ ChildProcess.closeH case _ of
            Exit.Normally n | n == 0 || n == 1 ->
                Ref.read outputRef >>= case _ of
                    x:_ | String.contains (Pattern "Build succeeded.") x -> do
                        LSP.ServerRequest.window_showInfoMessage lspConn
                            "Build succeeded."
                        cb (Right unit)

                    x:_ | String.contains (Pattern "Failed to build.") x -> do
                        LSP.ServerRequest.window_showErrorMessage lspConn
                            "Build failed."
                        cb (Right unit)

                    _ ->
                        cb <<< Left $ error "Fatal: Could not parse build output."
            _ ->
                cb <<< Left $ error "Fatal: Build interrupted."

        buildP # once_ ChildProcess.errorH
            (cb <<< Left <<< SysError.toError)

compilingStatus :: String -> Maybe { current :: String, total :: String }
compilingStatus input = do
    re <- hush $ Regex.regex """(\d+)\D+(\d+).+Compiling""" Flags.noFlags
    matches <- Regex.match re input
    current <- join $ matches !! 1
    total <- join $ matches !! 2
    pure { current, total }

getSourcePaths :: String -> String -> Effect (Array FilePath)
getSourcePaths spago workspace = do
    buf <- ChildProcess.execFileSync' spago ["sources"]
                (_ { cwd = Just workspace
                   })
    text <- Buffer.toString Encoding.UTF8 buf
    pure $ Array.filter (not <<< String.null)
         $ String.lines text

killServer :: forall a. Env App -> Error -> Aff a
killServer (Env { log, idePort }) err = do
    liftEffect $ log Log.Error (show err)
    PursIDE.send_ Command.Quit idePort
    throwError err

handlers :: Env App -> Effect Unit
handlers env@(Env { lspConn, documents, idePort }) = do
    LSP.ClientRequest.shutdown lspConn $ JS.Promise.fromAff do
        PursIDE.send_ Command.Quit idePort

    mapRequestHandler      TextDocument.hover      LSP.ClientRequest.textDocument_hover
    mapRequestHandler      TextDocument.definition LSP.ClientRequest.textDocument_definition
    mapRequestHandler      TextDocument.references LSP.ClientRequest.textDocument_references
    mapNotificationHandler TextDocument.didSave    LSP.ClientNotification.textDocument_didSave

    where
        mapRequestHandler
            :: forall i o. (JS.Flatten o o) =>
               (i -> App o)
            -> (LSP.Connection -> (i -> Effect (JS.Promise o)) -> Effect Unit)
            -> Effect Unit
        mapRequestHandler appHandler handler =
            handler lspConn \args -> JS.Promise.fromAff do
                eRes <- Aff.try $ runApp env (appHandler args)
                case eRes of
                    Left e  -> killServer env e
                    Right x -> pure x

        mapNotificationHandler
            :: forall i.
               (i -> App Unit)
            -> (LSP.TextDocuments -> (i -> Effect Unit) -> Effect Unit)
            -> Effect Unit
        mapNotificationHandler appHandler handler =
            handler documents \args -> Aff.launchAff_ do
                eRes <- Aff.try $ runApp env (appHandler args)
                case eRes of
                    Left e  -> killServer env e
                    Right x -> pure x
