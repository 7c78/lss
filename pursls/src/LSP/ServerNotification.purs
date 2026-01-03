module LSP.ServerNotification
    ( module LSP.Types
    , textDocument_publishDiagnostics
    ) where

import Prelude
import Effect (Effect)
import LSP.Types

foreign import textDocument_publishDiagnostics
    :: Connection
    -> PublishDiagnosticParams
    -> Effect Unit
