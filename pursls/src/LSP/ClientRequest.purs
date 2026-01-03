module LSP.ClientRequest
    ( module LSP.Types
    , shutdown
    , textDocument_hover
    , textDocument_definition
    , textDocument_references
    ) where

import Prelude
import Data.Nullable (Nullable)
import Effect (Effect)
import Promise as JS
import LSP.Types

foreign import shutdown
    :: Connection
    -> Effect (JS.Promise Unit)
    -> Effect Unit

foreign import textDocument_hover
    :: Connection
    -> (HoverParams -> Effect (JS.Promise (Nullable Hover)))
    -> Effect Unit

foreign import textDocument_definition
    :: Connection
    -> (DefinitionParams -> Effect (JS.Promise (Array LocationLink)))
    -> Effect Unit

foreign import textDocument_references
    :: Connection
    -> (ReferenceParams -> Effect (JS.Promise (Array Location)))
    -> Effect Unit
