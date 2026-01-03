module LSP.TextDocuments
    ( module LSP.Types
    , new
    , get
    , all
    ) where

import Prelude
import Data.Nullable (Nullable, toMaybe)
import Data.Maybe (Maybe)
import Effect (Effect)
import LSP.Types

foreign import new :: Connection -> Effect TextDocuments
foreign import _all :: TextDocuments -> Effect (Array TextDocument)
foreign import _get :: TextDocuments -> URI -> Effect (Nullable TextDocument)

get :: TextDocuments -> URI -> Effect (Maybe TextDocument)
get docs uri = toMaybe <$> _get docs uri

all :: TextDocuments -> Effect (Array TextDocument)
all = _all
