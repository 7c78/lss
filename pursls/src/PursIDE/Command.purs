module PursIDE.Command where

import Prelude
import Data.Maybe (Maybe)
import Data.Argonaut as Json
import Data.Argonaut (class EncodeJson, Json, (~>), (:=))
import Node.Path (FilePath)

data Command
    = Quit
    | Rebuild FilePath
    | Type String (Array Filter) (Maybe String)
    | Usages String Namespace String
    | List_Imports FilePath

data Filter
    = Filter_Exact String
    | Filter_Prefix String
    | Filter_Module (Array String)
    | Filter_Namespace (Array Namespace)
    | Filter_Declaration (Array DeclarationType)
    | Filter_Dependency String (Maybe String)

-- https://github.com/purescript/purescript/blob/8ac0fb2962a7df318a74216872465dc2868c6064/src/Language/PureScript/Ide/Types.hs#L25
data DeclarationType
    = Declaration_Value
    | Declaration_Type
    | Declaration_TypeSynonym
    | Declaration_DataConstructor
    | Declaration_TypeClass
    | Declaration_ValueOperator
    | Declaration_TypeOperator
    | Declaration_Module

-- | https://github.com/purescript/purescript/blob/8ac0fb2962a7df318a74216872465dc2868c6064/src/Language/PureScript/Ide/Types.hs#L315
data Namespace
    = NS_Value
    | NS_Type
    | NS_Module

instance EncodeJson Command where
    encodeJson = case _ of
        Quit ->
            command "quit" Json.jsonEmptyObject
        Rebuild file ->
            command "rebuild" $
                "file" := file
                ~> Json.jsonEmptyObject
        Type search filters currentModule ->
            command "type" $
                "search" := search
                ~> "filters" := filters
                ~> "currentModule" := currentModule
                ~> Json.jsonEmptyObject
        Usages mod ns ident ->
            command "usages" $
                "module" := mod
                ~> "namespace" := ns
                ~> "identifier" := ident
                ~> Json.jsonEmptyObject
        List_Imports filePath ->
            command "list" $
                "type" := "import"
                ~> "file" := filePath
                ~> Json.jsonEmptyObject


command :: forall a. (EncodeJson a) => String -> a -> Json
command name params =
    "command" := name
    ~> "params" := params
    ~> Json.jsonEmptyObject

instance EncodeJson Filter where
    encodeJson = case _ of
        Filter_Exact search ->
            filter "exact" $
                "search" := search
                ~> Json.jsonEmptyObject
        Filter_Prefix search ->
            filter "prefix" $
                "search" := search
                ~> Json.jsonEmptyObject
        Filter_Module modules ->
            filter "modules" $
                "modules" := modules
                ~> Json.jsonEmptyObject
        Filter_Namespace nss ->
            filter "namespace" $
                "namespaces" := nss
                ~> Json.jsonEmptyObject
        Filter_Declaration decls ->
            filter "declarations" (map show decls)
        Filter_Dependency moduleText qualifier ->
            filter "dependencies" $
                "moduleText" := moduleText
                ~> "qualifier" := qualifier
                ~> Json.jsonEmptyObject

filter :: forall a. (EncodeJson a) => String -> a -> Json
filter name params =
    "filter" := name
    ~> "params" := params
    ~> Json.jsonEmptyObject

instance Show DeclarationType where
    show = case _ of
        Declaration_Value           -> "value"
        Declaration_Type            -> "type"
        Declaration_TypeSynonym     -> "synonym"
        Declaration_DataConstructor -> "dataconstructor"
        Declaration_TypeClass       -> "typeclass"
        Declaration_ValueOperator   -> "valueoperator"
        Declaration_TypeOperator    -> "typeoperator"
        Declaration_Module          -> "module"

derive instance Eq DeclarationType

-- https://github.com/purescript/purescript/blob/8ac0fb2962a7df318a74216872465dc2868c6064/src/Language/PureScript/Ide/Types.hs#L319
instance EncodeJson Namespace where
    encodeJson = case _ of
         NS_Value  -> Json.fromString "value"
         NS_Type   -> Json.fromString "type"
         NS_Module -> Json.fromString "module"

-- https://github.com/purescript/purescript/blob/8ac0fb2962a7df318a74216872465dc2868c6064/src/Language/PureScript/Ide/Util.hs#L59
namespaceForDeclaration :: DeclarationType -> Namespace
namespaceForDeclaration = case _ of
    Declaration_Value           -> NS_Value
    Declaration_Type            -> NS_Type
    Declaration_TypeSynonym     -> NS_Type
    Declaration_DataConstructor -> NS_Value
    Declaration_TypeClass       -> NS_Type
    Declaration_ValueOperator   -> NS_Value
    Declaration_TypeOperator    -> NS_Type
    Declaration_Module          -> NS_Module
