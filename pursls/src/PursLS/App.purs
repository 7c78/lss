module PursLS.App
    ( module PursLS.App.Env
    , App
    , runApp
    ) where

import Prelude

import Control.Monad.Error.Class (class MonadThrow)
import Control.Monad.Reader (class MonadReader, class MonadAsk, ReaderT)
import Control.Monad.Reader as Reader
import Effect.Class (class MonadEffect)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Effect.Exception (Error)
import PursLS.App.Env

newtype App a = App (ReaderT (Env App) Aff a)

runApp :: forall a. Env App -> App a -> Aff a
runApp env (App m) = Reader.runReaderT m env

derive newtype instance Functor     App
derive newtype instance Apply       App
derive newtype instance Applicative App
derive newtype instance Bind        App
derive newtype instance Monad       App
derive newtype instance MonadEffect App
derive newtype instance MonadAff    App
derive newtype instance MonadAsk    (Env App) App
derive newtype instance MonadReader (Env App) App
derive newtype instance MonadThrow  Error App
