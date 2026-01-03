module PursLS.Handler.TextDocument.DidSave where

import Prelude

import Data.MMap as MMap
import Data.String.Safe as String
import LSP.URI as URI
import LSP.ClientNotification as LSP
import TaskQueue as TaskQueue
import PursLS.App (App, dependencies, taskQueue)
import PursLS.App.Log as Log
import PursLS.PursIDE as PursIDE
import PursLS.LSP.TextDocument as LSP.TextDocument

didSave :: LSP.TextDocumentChangeEvent -> App Unit
didSave { document: { uri } } = do
    Log.debug $ String.unlines
        [ "Server.Handler.TextDocument.DidSave.didSave"
        , "    uri: " <> uri
        ]

    MMap.delete uri =<< dependencies

    let uri' = URI.parse uri
    when (LSP.TextDocument.isPursFile uri') $
        taskQueue >>= TaskQueue.enqueue do
            diagnostics <- PursIDE.rebuild uri'.fsPath
            LSP.TextDocument.publishDiagnostics { uri, diagnostics }
