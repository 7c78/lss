module LSP.TextDocument
    ( module LSP.Types
    , getText
    , getTextAtRange
    ) where

import Prelude
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import LSP.Types

foreign import _getText :: TextDocument -> Effect String
foreign import _getTextAtRange :: Range -> TextDocument -> Effect String


getText :: forall m. (MonadEffect m) =>
           TextDocument -> m String
getText = liftEffect <<< _getText

getTextAtRange :: forall m. (MonadEffect m) =>
                  Range -> TextDocument -> m String
getTextAtRange range = liftEffect <<< _getTextAtRange range
