module PursLS.Handler.TextDocument.Hover where

import Debug.Trace as Debug

import Prelude

import Data.Maybe (Maybe(..), fromMaybe)
import Data.Nullable (Nullable, toNullable)
import Data.String.Safe as String
import LSP.Types as LSP
import Purs.Token as Purs.Token
import PursIDE.Result as Result
import PursLS.App (App)
import PursLS.App.Log as Log
import PursLS.Purs as Purs
import PursLS.PursIDE as PursIDE
import PursLS.LSP.TextDocuments as TextDocuments

hover :: LSP.HoverParams -> App (Nullable LSP.Hover)
hover params@{ textDocument: { uri }, position } = toNullable <$> do
    Log.debug $ String.unlines
        [ "Server.Handler.TextDocument.Hover.hover"
        , "params: " <> Debug.inspect params
        ]

    doc <- TextDocuments.get uri
    Purs.identifierAtPoint doc position >>= case _ of
        Nothing ->
            pure Nothing
        Just ident -> do
            typ <- PursIDE.typeInfo uri ident.name ident.qualifier
            pure $ typ <#> \t ->
                LSP.Hover { contents: LSP.markdownContent (renderType ident t)
                          , range: { start: { line: position.line, character: ident.range.left }
                                   , end: { line: position.line, character: ident.range.right }
                                   }
                          }

renderType :: Purs.Token.NameInfo -> Result.Type -> String
renderType { name } (Result.Type t) =
    String.unlines
        [ "```purescript"
        , name <> " ∷ " <> t.type
        , "```"
        , if String.null doc
              then ""
              else "\n" <> doc
        ]
    where
        doc = fromMaybe "" t.documentation
