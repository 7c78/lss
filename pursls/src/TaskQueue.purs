module TaskQueue where

import Prelude

import Data.List (List(..))
import Data.List as List
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (Ref)
import Effect.Ref as Ref

type TaskQueue m =
    Ref { queue   :: List (m Unit)
        , running :: Boolean
        }

new :: forall m. (MonadEffect m) => Effect (TaskQueue m)
new = Ref.new { queue: Nil, running: false }

enqueue :: forall m. (MonadEffect m) =>
           m Unit -> TaskQueue m -> m Unit
enqueue task qRef = do
    running <- liftEffect do
        { queue, running } <- Ref.read qRef
        Ref.modify_ (_ { queue = queue `List.snoc` task }) qRef
        pure running
    when (not running) $
        dequeue qRef

dequeue :: forall m. (MonadEffect m) =>
           TaskQueue m -> m Unit
dequeue qRef = do
    { queue } <- liftEffect $ Ref.read qRef
    case queue of
        Nil -> do
            liftEffect $ Ref.modify_ (_ { running = false }) qRef
        Cons task queue' -> do
            liftEffect $ Ref.write { running: true, queue: queue' } qRef
            task
            dequeue qRef
