module Control.Monad.Safe where

import Prelude
import Control.Apply (lift2)

infixr 2 orM as ^||
orM :: forall m. (Monad m) => m Boolean -> m Boolean -> m Boolean
orM = lift2 (||)

infixr 3 andM as ^&&
andM :: forall m. (Monad m) => m Boolean -> m Boolean -> m Boolean
andM = lift2 (&&)

whileM :: forall m. (Monad m) => m Boolean -> m Unit -> m Unit
whileM mb m = mb >>= \b -> when b $ m *> whileM mb m

untilM :: forall m. (Monad m) => m Boolean -> m Unit -> m Unit
untilM mb m = mb >>= \b -> when (not b) $ m *> untilM mb m
