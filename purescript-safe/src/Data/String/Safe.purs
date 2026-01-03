module Data.String.Safe
    ( module Exports
    , charAt
    , init
    , tail
    , words
    , unwords
    , lines
    , unlines
    ) where

import Data.String
    ( take
    , length
    , drop
    , trim
    , toUpper
    , toLower
    , split
    , replaceAll
    , replace
    , null
    , joinWith

    ) as Exports

import Data.String.CodeUnits
    ( singleton
    , toCharArray
    , fromCharArray
    , contains
    , takeWhile
    , dropWhile
    , slice
    ) as Exports

import Data.String.Unsafe
    ( char
    ) as Exports

foreign import charAt :: Int -> String -> Char
foreign import init :: String -> String
foreign import tail :: String -> String

foreign import words :: String -> Array String
foreign import unwords :: Array String -> String

foreign import lines :: String -> Array String
foreign import unlines :: Array String -> String
