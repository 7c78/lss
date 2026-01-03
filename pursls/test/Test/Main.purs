module Test.Main where

import Prelude

import Test.Spec.Reporter as Spec.Reporter
import Test.Spec.Runner.Node (runSpecAndExitProcess')
import Test.Spec.Runner.Node.Config (defaultConfig)

import Test.PursIDE.Server as PursIDE.Server
import Test.Purs.Dependency as Purs.Dependency

import Effect (Effect)

main :: Effect Unit
main = runSpecAndExitProcess' @Effect { defaultConfig, parseCLIOptions: true } [Spec.Reporter.consoleReporter] do
    PursIDE.Server.spec
    Purs.Dependency.spec
