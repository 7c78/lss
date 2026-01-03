module PursIDE.Server where

import Prelude

import Data.Either (Either(..))
import Data.Array.Safe as Array
import Data.Argonaut as Json
import Data.Argonaut (class DecodeJson)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Exception (Error, error)
import Node.Path (FilePath)
import Node.ChildProcess as ChildProcess
import Node.Errors.SystemError as SysError
import Node.EventEmitter (once_)
import Node.Which (which)
import PursIDE.Command (Command)
import PursIDE.Result (decodeResponse)

-- https://github.com/purescript/purescript/blob/8ac0fb2962a7df318a74216872465dc2868c6064/app/Command/Ide.hs#L155
type ServerOptions =
    { directory :: FilePath
    , port      :: Int
    , globs     :: Array FilePath
    }

start :: (Error -> Effect Unit) -> ServerOptions -> Effect Unit
start onError { port, globs, directory } = do
    purs <- Array.head <$> which "purs"
    let args =  ["--port", show port]
             <> ["--directory", directory]
             <> ["--log-level", "none"]
             <> globs
    cp <- ChildProcess.spawn purs (["ide", "server"] <> args)
    cp # once_ ChildProcess.errorH
        (onError <<< SysError.toError)
    cp # once_ ChildProcess.closeH \exit ->
        onError <<< error $ "Fatal: Purs IDE terminated (" <> show exit <> ")"

foreign import _send
    :: Int                     -- port
    -> String                  -- command
    -> (String -> Effect Unit) -- resolve
    -> (Error -> Effect Unit)  -- reject
    -> Effect Unit

send :: forall a b. (DecodeJson a) => (DecodeJson b) =>
        Command -> Int -> Aff (Either a b)
send cmd port = do
    Aff.makeAff \cb -> Aff.nonCanceler <$
        _send port (Json.stringify (Json.encodeJson cmd))
            (decodeResponse >>> case _ of
                Left e  -> cb (Left (error e))
                Right x -> cb (Right x))
            (cb <<< Left)

send_ :: Command -> Int -> Aff Unit
send_ cmd port = do
    Aff.makeAff \cb -> Aff.nonCanceler <$
        _send port (Json.stringify (Json.encodeJson cmd))
            (const $ cb (Right unit))
            (cb <<< Left)
