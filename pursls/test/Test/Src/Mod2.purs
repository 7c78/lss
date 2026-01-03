module Test.Src.Mod2 where

import Prelude
import Effect (Effect)
import Effect.Class.Console (log) as Console
import Test.Src.Mod1 as Mod1

main :: Effect Unit
main = do
    let x = Mod1.myFun 1 3
    Console.log $ show x

someDefinition1 :: Int
someDefinition1 = Mod1.myFun 2 4
