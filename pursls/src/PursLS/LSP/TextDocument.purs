module PursLS.LSP.TextDocument where

import Prelude

import Control.Monad.Reader as Reader
import Effect.Class (liftEffect)
import Node.Path as Path
import LSP.ServerNotification as LSP
import PursLS.App (App)
import PursLS.App.Env (Env(..))

publishDiagnostics :: LSP.PublishDiagnosticParams -> App Unit
publishDiagnostics params = do
    Env { lspConn } <- Reader.ask
    liftEffect $
        LSP.textDocument_publishDiagnostics lspConn params

isPursFile :: LSP.ParsedURI -> Boolean
isPursFile uri =  Path.extname uri.fsPath == ".purs"
               && uri.scheme == "file"
