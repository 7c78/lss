module Debug.Trace where

import Prelude

infixl 8 trace as ?
foreign import trace :: forall a. String -> a -> Unit
-- let/where _ =

foreign import inspect :: forall a. a -> String
