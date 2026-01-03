module Node.Which where

import Prelude

import Data.Maybe (fromMaybe)
import Data.String.Safe as String
import Data.String.Pattern (Pattern(..))
import Data.Array.Safe as Array
import Effect (Effect)
import Node.Path (FilePath, delimiter, concat)
import Node.Process as Process

which :: String -> Effect (Array FilePath)
which cmd = do
    path <- pure fromMaybe <*> pure "" <*> Process.lookupEnv "PATH"
    pure $ map (\p -> concat [p, cmd])
         $ Array.filter (String.contains (Pattern cmd))
         $ String.split (Pattern delimiter) path
