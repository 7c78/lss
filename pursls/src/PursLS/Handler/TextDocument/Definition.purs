module PursLS.Handler.TextDocument.Definition where

import Debug.Trace as Debug

import Prelude

import Data.Maybe (Maybe(..), maybe)
import Data.String.Safe as String
import Data.Char.Safe as Char
import LSP.Types as LSP
import LSP.URI as URI
import Purs.Token as Purs.Token
import PursIDE.Result as Result
import PursLS.App (App)
import PursLS.App.Log as Log
import PursLS.Purs (identifierAtPoint) as Purs
import PursLS.PursIDE as PursIDE
import PursLS.LSP.TextDocuments as TextDocuments

definition :: LSP.DefinitionParams -> App (Array LSP.LocationLink)
definition params@{ textDocument: { uri }, position } = do
    Log.debug $ String.unlines
        [ "Server.Handler.TextDocument.Definition.definition"
        , "params: " <> Debug.inspect params
        ]

    doc <- TextDocuments.get uri
    Purs.identifierAtPoint doc position >>= case _ of
        Nothing ->
            pure []
        Just ident -> do
            getModuleType ident >>= case _ of
                Just { moduleType: Result.Type typ, moduleName } ->
                    pure $ case typ.definedAt of
                        Nothing ->
                            []
                        Just definedAt ->
                            let targetStart = PursIDE.sourcePositionToLSPPosition definedAt.start
                                targetRange =
                                    { start: targetStart
                                    , end: targetStart { line = targetStart.line + 1 }
                                    }
                                originSelectionRange =
                                    { start: { line: position.line
                                             , character: ident.range.right - (String.length moduleName)
                                             }
                                    , end: { line: position.line
                                           , character: ident.range.right
                                           }
                                    }
                            in [ LSP.LocationLink { targetUri: URI.fromFilePath definedAt.name
                                                  , originSelectionRange
                                                  , targetRange
                                                  , targetSelectionRange: targetRange
                                                  } ]
                Nothing ->
                    PursIDE.typeInfo uri ident.name ident.qualifier <#> case _ of
                        Just (Result.Type { definedAt: Just definedAt }) ->
                            let targetRange = PursIDE.sourceSpantoLSPRange definedAt
                                originSelectionRange =
                                    { start: { line: position.line, character: ident.range.left }
                                    , end: { line: position.line, character: ident.range.right }
                                    }
                            in [ LSP.LocationLink { targetUri: URI.fromFilePath definedAt.name
                                                  , originSelectionRange
                                                  , targetRange
                                                  , targetSelectionRange: targetRange
                                                  } ]
                        _ ->
                            []

getModuleType :: Purs.Token.NameInfo -> App (Maybe { moduleType :: Result.Type, moduleName :: String })
getModuleType ident =
    if not <<< Char.isUpper $ String.charAt 0 ident.name then
        pure Nothing
    else do
        let qualifier = maybe "" (_ <> ".") ident.qualifier
            mod = qualifier <> ident.name
        typ <- PursIDE.moduleInfo mod
        pure $ typ <#> \t ->
            { moduleType: t
            , moduleName: mod
            }
