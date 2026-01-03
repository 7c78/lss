module Node.FS.Internal where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Exception (try)
import Node.Process as Process
import Node.OS as OS
import Node.Path (FilePath)
import Node.Path as Path
import Node.FS.Sync as FS
import Node.FS.Stats (isDirectory)

getXdgDir :: String -> String -> Effect FilePath
getXdgDir envVar defaultSuffix = do
    val <- Process.lookupEnv envVar
    case val of
        Just d ->
            pure d
        Nothing -> do
             home <- OS.homedir
             pure $ Path.concat [home, defaultSuffix]

mkdirp :: FilePath -> Effect Unit
mkdirp path = do
    try (FS.stat path) >>= case _ of
        Right s
            | isDirectory s ->
            pure unit

        _ -> do
            let parent = Path.dirname path
            when (parent /= path) do
                mkdirp parent
            FS.mkdir path
