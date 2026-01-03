module PursLS.LSP.TextDocuments where

import Prelude

import Control.Monad.Error.Class (throwError)
import Control.Monad.Reader as Reader
import Data.String.Safe as String
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Effect.Exception (error)
import LSP.TextDocuments as TextDocuments
import LSP.TextDocuments (TextDocument, URI)
import PursLS.App (App)
import PursLS.App.Env (Env(..))

get :: URI -> App TextDocument
get uri = do
    Env {  documents } <- Reader.ask
    liftEffect $ TextDocuments.get documents uri >>= case _ of
        Nothing -> do
            throwError <<< error $ String.unlines
                [ "Server.LSP.TextDocuments.get"
                , "    uri: " <> uri
                ]
        Just doc ->
            pure doc
