module LSP.Connection
    ( module LSP.Types
    , new
    ) where

import Effect (Effect)
import LSP.Types

foreign import new :: Effect Connection
