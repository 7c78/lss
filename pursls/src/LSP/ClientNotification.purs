module LSP.ClientNotification
    ( module LSP.Types
    , textDocument_didSave
    , textDocument_didOpen
    ) where

import Prelude

import Effect (Effect)
import LSP.Types

foreign import textDocument_didSave
    :: TextDocuments
    -> (TextDocumentChangeEvent -> Effect Unit)
    -> Effect Unit

foreign import textDocument_didOpen
    :: TextDocuments
    -> (TextDocumentChangeEvent -> Effect Unit)
    -> Effect Unit
