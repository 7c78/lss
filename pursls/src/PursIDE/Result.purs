module PursIDE.Result where

import Prim hiding (Type)
import Prelude

import Data.Maybe (Maybe)
import Data.Either (Either(..))
import Data.Nullable (Nullable, toMaybe)
import Data.Bifunctor (lmap)
import Data.Argonaut as Json
import Data.Argonaut (class DecodeJson, Json, (.:))
import Effect.Exception.Unsafe as E
import Node.Path (FilePath)
import PursIDE.Command (DeclarationType(..))

newtype List_Imports = List_Imports
    { moduleName :: String
    , imports    :: Array Import
    }

newtype Type = Type
    { module          :: String
    , identifier      :: String
    , type            :: String
    , expandedType    :: String
    , exportedFrom    :: Array String
    , definedAt       :: Maybe SourceSpan
    , documentation   :: Maybe String
    , declarationType :: Maybe DeclarationType
    }

newtype Rebuild = Rebuild (Array BuildError)

newtype Usages = Usages (Array SourceSpan)

derive newtype instance Eq List_Imports
derive newtype instance Show List_Imports
derive newtype instance Eq Rebuild
derive newtype instance Show Rebuild
derive newtype instance Eq Type
derive newtype instance Show Type
derive newtype instance Eq Usages
derive newtype instance Show Usages

type Import =
    { module    :: String
    , qualifier :: Maybe String
    }

type SourcePosition =
    { line   :: Int
    , column :: Int
    }

type SourceSpan =
    { name  :: String
    , start :: SourcePosition
    , end   :: SourcePosition
    }

type BuildError =
    { message    :: String
    , errorCode  :: String
    , errorLink  :: String
    , filename   :: Maybe FilePath
    , moduleName :: Maybe String
    , position   :: Maybe ErrorPosition
    , suggestion :: Maybe ErrorSuggestion
    , allSpans   :: Array SourceSpan
    }

type ErrorPosition =
    { startLine   :: Int
    , startColumn :: Int
    , endLine     :: Int
    , endColumn   :: Int
    }

type ErrorSuggestion =
    { replacement  :: String
    , replaceRange :: Maybe ErrorPosition
    }

foreign import decode_List_Imports
    :: forall cons.
       cons
    -> (forall a. Nullable a -> Maybe a)
    -> (forall a. Json -> Either Json.JsonDecodeError a)
    -> (forall a. a -> Either Json.JsonDecodeError a)
    -> Json
    -> Either Json.JsonDecodeError List_Imports

instance DecodeJson List_Imports where
    decodeJson =
        decode_List_Imports List_Imports
            toMaybe
            (Left <<< Json.UnexpectedValue)
            Right

foreign import decode_Type
    :: forall cons.
       cons
    -> (String -> DeclarationType)
    -> (forall a. Nullable a -> Maybe a)
    -> (forall a. Json -> Either Json.JsonDecodeError a)
    -> (forall a. a -> Either Json.JsonDecodeError a)
    -> Json
    -> Either Json.JsonDecodeError Type

instance DecodeJson Type where
    decodeJson =
        decode_Type Type
            read_DeclarationType
            toMaybe
            (Left <<< Json.UnexpectedValue)
            Right

read_DeclarationType :: String -> DeclarationType
read_DeclarationType = case _ of
    "value"           -> Declaration_Value
    "type"            -> Declaration_Type
    "synonym"         -> Declaration_TypeSynonym
    "dataconstructor" -> Declaration_DataConstructor
    "typeclass"       -> Declaration_TypeClass
    "valueoperator"   -> Declaration_ValueOperator
    "typeoperator"    -> Declaration_TypeOperator
    "module"          -> Declaration_Module
    typ               -> E.unsafeThrow $ "read_DeclarationType: invalid type " <> typ

foreign import decode_Rebuild
    :: forall cons.
       cons
    -> (forall a. Nullable a -> Maybe a)
    -> (forall a. Json -> Either Json.JsonDecodeError a)
    -> (forall a. a -> Either Json.JsonDecodeError a)
    -> Json
    -> Either Json.JsonDecodeError Rebuild

instance DecodeJson Rebuild where
    decodeJson =
        decode_Rebuild Rebuild
            toMaybe
            (Left <<< Json.UnexpectedValue)
            Right

foreign import decode_Usages
    :: forall cons.
       cons
    -> (forall a. Json -> Either Json.JsonDecodeError a)
    -> (forall a. a -> Either Json.JsonDecodeError a)
    -> Json
    -> Either Json.JsonDecodeError Usages

instance DecodeJson Usages where
    decodeJson =
        decode_Usages Usages
            (Left <<< Json.UnexpectedValue)
            Right

decodeResponse :: forall a b. (DecodeJson a) => (DecodeJson b) =>
                  String -> Either String (Either a b)
decodeResponse s = lmap Json.printJsonDecodeError do
    json <- Json.parseJson s
    obj <- Json.decodeJson json
    resultType <- obj .: "resultType"
    case resultType of
        "success" -> do
            result <- obj .: "result"
            pure $ Right result
        _ -> do
            result <- obj .: "result"
            pure $ Left result
