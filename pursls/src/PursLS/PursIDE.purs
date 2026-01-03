module PursLS.PursIDE where

import Prelude

import Control.Monad.Reader as Reader
import Control.Monad.Error.Class (throwError)
import Data.Argonaut (class DecodeJson)
import Data.Argonaut as Json
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), maybe)
import Data.String.Safe as String
import Data.Array.Safe as Array
import Effect.Aff.Class (liftAff)
import Effect.Exception (error)
import Node.Path (FilePath)
import PursIDE.Server as PursIDE
import PursIDE.Command as Command
import PursIDE.Command (Command, Filter(..), DeclarationType(..))
import PursIDE.Result as Result
import LSP.Types as LSP
import PursLS.App (App)
import PursLS.App.Log as Log
import PursLS.App.Env (Env(..))
import PursLS.Purs as Purs

sendE :: forall a b. (DecodeJson a) => (DecodeJson b) =>
         Command -> App (Either a b)
sendE cmd = do
    Env { idePort } <- Reader.ask
    liftAff $ PursIDE.send cmd idePort

send :: forall a. (DecodeJson a) => Command -> App a
send cmd =
    sendE cmd >>= case _ of
        Left e -> do
            throwError <<< error $ String.unlines
                [ "Server.PursIDE.send"
                , "    command: " <> Json.stringify (Json.encodeJson cmd)
                , "    error: " <> e
                ]
        Right x ->
            pure x

typeInfo :: FilePath -> String -> Maybe String -> App (Maybe Result.Type)
typeInfo filePath identifier qualifier = do
    Log.debug $ String.unlines
        [ "Server.PursIDE.typeInfo"
        , "    identifier: " <> identifier
        , "    file: " <> filePath
        ]

    { dependencyText } <- Purs.getDependency filePath
    let filter = [Filter_Dependency dependencyText qualifier]
    Array.safeHead <$> send (Command.Type identifier filter Nothing)

moduleInfo :: String -> App (Maybe Result.Type)
moduleInfo identifier = do
    Log.debug $ String.unlines
        [ "Server.PursIDE.moduleInfo"
        , "    identifier: " <> identifier
        ]

    let filter = [Filter_Declaration [Declaration_Module]]
    Array.safeHead <$> send (Command.Type identifier filter Nothing)

rebuild :: FilePath -> App (Array LSP.Diagnostic)
rebuild path = do
    built <- sendE (Command.Rebuild path)
    pure $ case built of
        Left (Result.Rebuild errors) ->
            map (buildErrorToLSPDiagnostic 1) errors
        Right (Result.Rebuild warnings) ->
            map (buildErrorToLSPDiagnostic 2) warnings

buildErrorToLSPDiagnostic :: Int -> Result.BuildError -> LSP.Diagnostic
buildErrorToLSPDiagnostic severity e =
    LSP.Diagnostic { severity
                   , range: maybe range0 errorPositionToLSPRange e.position
                   , code: e.errorCode
                   , source: "PureScript"
                   , message: e.message
                   }
    where
        range0 = { start: { line: 1, character: 1 }
                 , end: { line: 1, character: 1 }
                 }

errorPositionToLSPRange :: Result.ErrorPosition -> LSP.Range
errorPositionToLSPRange { startLine, startColumn, endLine, endColumn } =
    { start: { line: startLine - 1, character: startColumn - 1 }
    , end: { line: endLine - 1, character: endColumn - 1 }
    }

sourcePositionToLSPPosition :: Result.SourcePosition -> LSP.Position
sourcePositionToLSPPosition { line, column } =
    { line: line - 1
    , character: column - 1
    }

sourceSpantoLSPRange :: Result.SourceSpan -> LSP.Range
sourceSpantoLSPRange { start, end } =
    { start: sourcePositionToLSPPosition start
    , end: sourcePositionToLSPPosition end
    }
