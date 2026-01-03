module LSP.ServerRequest
    ( module LSP.Types
    , window_showWarningMessageWithActions
    , window_showWarningMessage
    , window_showInfoMessage
    , window_showErrorMessage
    ) where

import Prelude

import Data.Nullable (Nullable)
import Effect (Effect)
import Promise as JS
import LSP.Types

foreign import window_showWarningMessageWithActions
    :: Connection
    -> String
    -> Array MessageActionItem
    -> Effect (JS.Promise (Nullable MessageActionItem))

foreign import window_showWarningMessage
    :: Connection
    -> String
    -> Effect Unit

foreign import window_showInfoMessage
    :: Connection
    -> String
    -> Effect Unit

foreign import window_showErrorMessage
    :: Connection
    -> String
    -> Effect Unit
