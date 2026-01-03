module Test.Purs.Dependency where


import Prelude

import Test.Spec (SpecT, it)
import Test.Spec as Spec
import Test.Spec.Assertions as Assert

import Purs.Dependency as Purs

import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Node.Process (cwd) as Process
import Node.Encoding as Encoding
import Node.FS.Aff as FS
import Node.Path (FilePath)

type TextDocument =
    { path     :: FilePath
    , contents :: String
    }

type TestInput =
    { mod1 :: TextDocument
    , mod2 :: TextDocument
    }

loadSources :: Aff TestInput
loadSources = do
    cwd <- liftEffect $ Process.cwd
    let mod1Path = cwd <> "/test/Test/Src/Mod1.purs"
        mod2Path = cwd <> "/test/Test/Src/Mod2.purs"
    mod1Contents <- FS.readTextFile Encoding.UTF8 mod1Path
    mod2Contents <- FS.readTextFile Encoding.UTF8 mod2Path
    pure { mod1: { path: mod1Path, contents: mod1Contents }
         , mod2: { path: mod2Path, contents: mod2Contents }
         }

spec :: SpecT Aff Unit Effect Unit
spec = Spec.beforeAll loadSources
     $ Spec.describe "Purs.Dependency" do

    it "Mod1" \{ mod1 } -> do
        Purs.parseDependency mod1.contents `Assert.shouldEqual`
            { moduleName: "Test.Src.Mod1"
            , dependencyText: "module Test.Src.Mod1 where\n\nimport Prelude\n\n"
            }
