module PursLS.Purs where

import Prelude
import Data.MMap as MMap
import Data.Maybe (Maybe(..))
import Data.String.Safe as String
import Purs.Dependency (Dependency, parseDependency) as Purs
import Purs.Token (NameInfo, identifierAtPoint) as Purs
import LSP.Types as LSP
import LSP.TextDocument as TextDocument
import PursLS.App (App, dependencies)
import PursLS.App.Log as Log
import PursLS.LSP.TextDocuments as TextDocuments

getDependency :: LSP.URI -> App Purs.Dependency
getDependency uri =
    dependencies >>= MMap.lookup uri >>= case _ of
        Nothing -> do
            Log.debug $ String.unlines
                [ "Server.Purs.getDependency (parse module text)"
                , "    uri: " <> uri
                ]

            moduleText <- TextDocument.getText =<< TextDocuments.get uri
            let dep = Purs.parseDependency moduleText
            MMap.insert uri dep =<< dependencies
            pure dep

        Just dep -> do
            Log.debug $ String.unlines
                [ "Server.Purs.getDependency (get from cache)"
                , "    file: " <> uri
                ]

            pure dep

identifierAtPoint :: LSP.TextDocument -> LSP.Position -> App (Maybe Purs.NameInfo)
identifierAtPoint doc { line, character } = do
    lineText <- TextDocument.getTextAtRange lineRange doc
    pure $ Purs.identifierAtPoint lineText character
    where
        lineRange =
            { start: { line, character: 0 }
            , end: { line, character: character + 100 }
            }
