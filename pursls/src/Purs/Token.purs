module Purs.Token where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Newtype (un)
import PureScript.CST.Lexer as Lexer
import PureScript.CST.TokenStream as TokenStream
import PureScript.CST.Types as Token

type NameRange =
    { left  :: Int
    , right :: Int
    }

type NameInfo =
    { name      :: String
    , range     :: NameRange
    , qualifier :: Maybe String
    }

identifierAtPoint :: String -> Int -> Maybe NameInfo
identifierAtPoint line column =
    go $ TokenStream.step $ Lexer.lex line
    where
        go (TokenStream.TokenCons sourceToken _ stream _)
            | column < sourceToken.range.start.column =
                Nothing
            | column >= sourceToken.range.end.column =
                go $ TokenStream.step stream
            | otherwise =
                case sourceToken.value of
                    Token.TokLowerName mod name  -> just sourceToken mod name
                    Token.TokUpperName mod name  -> just sourceToken mod name
                    Token.TokOperator mod name   -> just sourceToken mod name
                    Token.TokSymbolName mod name -> just sourceToken mod name
                    _                            -> Nothing
        go _ = Nothing

        just sourceToken mod name =
            Just { range: { left: sourceToken.range.start.column
                          , right: sourceToken.range.end.column
                          }
                 , name
                 , qualifier: un Token.ModuleName <$> mod
                 }
