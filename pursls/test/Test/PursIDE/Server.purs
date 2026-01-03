module Test.PursIDE.Server where

import Prelude

import Test.Spec (SpecT, it)
import Test.Spec as Spec
import Test.Spec.Assertions as Assert

import PursIDE.Server as PursIDE
import PursIDE.Command as Command
import PursIDE.Command (Filter(..), DeclarationType(..), Namespace(..))
import PursIDE.Result as Result

import Data.Maybe (Maybe(..))
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Aff (Aff)
import Effect.Random as Random
import Node.Process (cwd) as Process
import Node.Process.Internal (sleep) as Process
import Node.Path (FilePath)
import Node.FS.Sync as FS
import Node.Encoding as Encoding

type TextDocument =
    { path     :: FilePath
    , contents :: String
    }

type TestInput =
    { port :: Int
    , mod1 :: TextDocument
    , mod2 :: TextDocument
    }

startServer :: Aff TestInput
startServer = liftEffect do
    cwd <- Process.cwd
    port <- Random.randomInt 16000 17000
    let globs = [cwd <> "/test/Test/Src/*.purs"]
    PursIDE.start (const $ pure unit)
        { directory: cwd
        , port
        , globs
        }
    Process.sleep 10
    let mod1Path = cwd <> "/test/Test/Src/Mod1.purs"
        mod2Path = cwd <> "/test/Test/Src/Mod2.purs"
    mod1Contents <- FS.readTextFile Encoding.UTF8 mod1Path
    mod2Contents <- FS.readTextFile Encoding.UTF8 mod2Path
    pure { port
         , mod1: { path: mod1Path, contents: mod1Contents }
         , mod2: { path: mod2Path, contents: mod2Contents }
         }

stopServer :: TestInput -> Aff Unit
stopServer { port } =
    PursIDE.send_ Command.Quit port

spec :: SpecT Aff Unit Effect Unit
spec = Spec.beforeAll startServer
     $ Spec.afterAll stopServer
     $ Spec.describe "PursIDE.Server" do

    Spec.describe "Command.Type" do
        it "type info" \{ port, mod1, mod2 } -> do
            let search = "myFun"
                qualifier = Just "Mod1"
                currentModule = Nothing
                depText = mod2.contents
                filter = [Filter_Dependency depText qualifier]
            eType :: Either String (Array Result.Type)
                  <- PursIDE.send (Command.Type search filter currentModule) port
            eType `Assert.shouldEqual` (Right
                [ Result.Type { module: "Test.Src.Mod1"
                              , identifier: "myFun"
                              , type: "Int → Int → Int"
                              , expandedType: "Int → Int → Int"
                              , exportedFrom: ["Test.Src.Mod1"]
                              , definedAt: Just { name: mod1.path
                                                , start: { line: 13, column: 1 }
                                                , end: { line: 13, column: 18 }
                                                }
                              , documentation: Just "Lsp Position line: 13, column: 1\nanother line of comments\n"
                              , declarationType: Just Declaration_Value
                              } ])

        it "module into" \{ port, mod2 } -> do
            let search = "Test.Src.Mod2"
                filter = [Filter_Declaration [Declaration_Module]]
                currentModule = Nothing
            eType :: Either String (Array Result.Type)
                  <- PursIDE.send (Command.Type search filter currentModule) port
            eType `Assert.shouldEqual` (Right
                [ Result.Type { module: "Test.Src.Mod2"
                              , identifier: "Test.Src.Mod2"
                              , type: "module"
                              , expandedType: "module"
                              , exportedFrom: ["Test.Src.Mod2"]
                              , definedAt: Just { name: mod2.path
                                                , start: { line: 1, column: 1 }
                                                , end: { line: 14, column: 33 }
                                                }
                              , documentation: Just ""
                              , declarationType: Just Declaration_Module
                              } ])

    Spec.describe "Command.Usages" do
        it "get references" \{ port, mod2 } -> do
            let mod = "Test.Src.Mod1"
                ident = "myFun"
            eRefs :: Either String Result.Usages
                  <- PursIDE.send (Command.Usages mod NS_Value ident) port
            eRefs `Assert.shouldEqual` (Right $ Result.Usages
                [ { name: mod2.path
                  , start: { line: 10, column: 13 }
                  , end: { line: 10, column: 23 }
                  }
                , { name: mod2.path
                  , start: { line: 14, column: 19 }
                  , end: { line: 14, column: 29 }
                  } ])
