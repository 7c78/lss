module Test.Src.Mod1 where

import Prelude

-- | Lsp Position line: 13, column: 1
-- | another line of comments
myFun ::
    -- | First int
    Int ->
    -- | Second int
    Int ->
    Int
myFun n m = n + m
