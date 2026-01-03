module Data.Array.Safe
    ( module Exports
    , index, (!)
    , head
    , safeHead
    , last
    , init
    , tail
    , deleteAt
    ) where

import Data.Array
    ( fromFoldable
    , toUnfoldable
    , singleton
    , range, (..)
    , replicate
    , null
    , length
    , elem
    , notElem
    , reverse
    , concat
    , concatMap
    , filter
    , foldl
    , foldr
    , foldMap
    , fold
    , foldM
    , intercalate
    , transpose
    , scanl
    , scanr
    , sort
    , sortBy
    , sortWith
    , slice
    , take
    , takeEnd
    , takeWhile
    , drop
    , dropEnd
    , dropWhile
    , zip
    , zipWith
    , unzip
    , all
    ) as Exports

import Data.Maybe (Maybe(..))
import Data.Array as Array
import Effect.Exception.Unsafe as E

infixl 8 index as !

index :: forall a. Array a -> Int -> a
index a i =
    case Array.index a i of
        Nothing -> E.unsafeThrow "Data.Array.Safe.index: out of bounds"
        Just x  -> x

head :: forall a. Array a -> a
head a =
    case Array.head a of
        Nothing -> E.unsafeThrow "Data.Array.Safe.head: out of bounds"
        Just x  -> x

safeHead :: forall a. Array a -> Maybe a
safeHead = Array.head

last :: forall a. Array a -> a
last a =
    case Array.last a of
        Nothing -> E.unsafeThrow "Data.Array.Safe.last: out of bounds"
        Just x  -> x

init :: forall a. Array a -> Array a
init a =
    case Array.init a of
        Nothing -> E.unsafeThrow "Data.Array.Safe.init: out of bounds"
        Just a' -> a'

tail :: forall a. Array a -> Array a
tail a =
    case Array.tail a of
        Nothing -> E.unsafeThrow "Data.Array.Safe.tail: out of bounds"
        Just a' -> a'

deleteAt :: forall a. Int -> Array a -> Array a
deleteAt i a =
    case Array.deleteAt i a of
        Nothing -> E.unsafeThrow "Data.Array.Safe.deleteAt: out of bounds"
        Just a' -> a'
