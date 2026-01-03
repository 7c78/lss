module PursLS.Handler.TextDocument.References where

import Debug.Trace as Debug

import Prelude

import Data.Maybe (Maybe(..))
import Data.String.Safe as String
import LSP.Types as LSP
import LSP.URI as URI
import PursIDE.Result as Result
import PursIDE.Command as Command
import PursLS.App (App)
import PursLS.App.Log as Log
import PursLS.Purs (identifierAtPoint) as Purs
import PursLS.PursIDE as PursIDE
import PursLS.LSP.TextDocuments as TextDocuments

references :: LSP.ReferenceParams -> App (Array LSP.Location)
references params@{ textDocument: { uri }, position } = do
    Log.debug $ String.unlines
        [ "Server.Handler.TextDocument.Definition.references"
        , "params: " <> Debug.inspect params
        ]

    doc <- TextDocuments.get uri
    Purs.identifierAtPoint doc position >>= case _ of
        Nothing ->
            pure []
        Just ident -> do
            mTyp <- PursIDE.typeInfo uri ident.name ident.qualifier
            case mTyp of
                Just (Result.Type typ@{ declarationType: Just decl }) -> do
                    let ns = Command.namespaceForDeclaration decl
                    Result.Usages refs <- PursIDE.send (Command.Usages typ.module ns ident.name)
                    pure $ refs <#> \ref ->
                        LSP.Location { uri: URI.fromFilePath ref.name
                                     , range: PursIDE.sourceSpantoLSPRange ref
                                     }
                _ ->
                    pure []
