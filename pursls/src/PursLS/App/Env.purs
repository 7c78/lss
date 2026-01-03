module PursLS.App.Env where

import Prelude
import Control.Monad.Reader (class MonadReader)
import Control.Monad.Reader as Reader
import Data.MMap (MMap)
import Node.Path (FilePath)
import LSP.Connection (Connection) as LSP
import LSP.TextDocuments (TextDocuments) as LSP
import TaskQueue (TaskQueue)
import Purs.Dependency (Dependency)
import PursLS.App.Log (class HasLogger, Log, LogLevel)

newtype Env m = Env
    { log          :: Log
    , loglevel     :: LogLevel
    , workspace    :: FilePath
    , lspConn      :: LSP.Connection
    , documents    :: LSP.TextDocuments
    , idePort      :: Int
    , dependencies :: MMap FilePath Dependency
    , taskQueue    :: TaskQueue m
    , spago        :: FilePath
    }

instance HasLogger (Env m) where
    getLog (Env { log }) = log
    getLogLevel (Env { loglevel }) = loglevel

dependencies :: forall m. (MonadReader (Env m) m) => m (MMap FilePath Dependency)
dependencies = do
    Env env <- Reader.ask
    pure env.dependencies


taskQueue :: forall m. (MonadReader (Env m) m) => m (TaskQueue m)
taskQueue = do
    Env env <- Reader.ask
    pure env.taskQueue
