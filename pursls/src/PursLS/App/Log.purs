module PursLS.App.Log
    ( module PursLS.App.Log.Internal
    , class HasLogger
    , getLog
    , getLogLevel
    , debug
    , info
    , warn
    , error
    ) where

import Prelude
import Control.Monad.Reader (class MonadReader, asks)
import Effect.Class (class MonadEffect, liftEffect)
import PursLS.App.Log.Internal (Log, LogLevel(..))

class HasLogger env where
    getLog      :: env -> Log
    getLogLevel :: env -> LogLevel

logWith :: forall env m. (HasLogger env) => (MonadReader env m) => (MonadEffect m) =>
           LogLevel -> String -> m Unit
logWith severity msg = do
    configuredSeverity <- asks getLogLevel
    when (severity >= configuredSeverity) do
        log <- asks getLog
        liftEffect $ log severity msg

debug :: forall env m. (HasLogger env) => (MonadReader env m) => (MonadEffect m) =>
         String -> m Unit
debug = logWith Debug

info :: forall env m. (HasLogger env) => (MonadReader env m) => (MonadEffect m) =>
        String -> m Unit
info = logWith Info

warn :: forall env m. (HasLogger env) => (MonadReader env m) => (MonadEffect m) =>
        String -> m Unit
warn = logWith Warn

error :: forall env m. (HasLogger env) => (MonadReader env m) => (MonadEffect m) =>
         String -> m Unit
error = logWith Error
