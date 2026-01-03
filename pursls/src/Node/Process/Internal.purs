module Node.Process.Internal where

import Prelude
import Effect (Effect)

foreign import sleep :: Int -> Effect Unit
