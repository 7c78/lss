module Data.MMap
    ( MMap
    , new
    , fromArray
    , insert
    , delete
    , lookup
    , lookupUnsafe
    ) where

import Prelude
import Data.Tuple (Tuple)
import Data.Maybe (Maybe(..))
import Data.Primitive (class Primitive)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)


foreign import data MMap :: Type -> Type -> Type

foreign import _new :: forall k v. Effect (MMap k v)
foreign import _fromArray :: forall k v. Array (Tuple k v) -> Effect (MMap k v)
foreign import _set :: forall k v. k -> v -> MMap k v -> Effect Unit
foreign import _delete :: forall k v. k -> MMap k v -> Effect Unit
foreign import _lookupUnsafe :: forall k v. k -> MMap k v -> Effect v
foreign import _lookup :: forall k v. (forall r. Maybe r) -> (forall r. r -> Maybe r) -> k -> MMap k v -> Effect (Maybe v)

fromArray :: forall m k v. (MonadEffect m) => (Primitive k) => Array (Tuple k v) -> m (MMap k v)
fromArray = liftEffect <<< _fromArray

new :: forall m k v. (MonadEffect m) => (Primitive k) => m (MMap k v)
new = liftEffect _new

insert :: forall m k v. (MonadEffect m) => (Primitive k) => k -> v -> MMap k v -> m Unit
insert k v = liftEffect <<< _set k v

delete :: forall m k v. (MonadEffect m) => (Primitive k) => k -> MMap k v -> m Unit
delete k = liftEffect <<< _delete k

lookupUnsafe :: forall m k v. (MonadEffect m) => (Primitive k) => k -> MMap k v -> m v
lookupUnsafe k = liftEffect <<< _lookupUnsafe k

lookup :: forall m k v. (MonadEffect m) => (Primitive k) => k -> MMap k v -> m (Maybe v)
lookup k = liftEffect <<< _lookup Nothing Just k
