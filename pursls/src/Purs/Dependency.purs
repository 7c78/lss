module Purs.Dependency where

type Dependency =
    { moduleName     :: String
    , dependencyText :: String
    }

foreign import parseDependency :: String -> Dependency
