module LSP.URI
    ( module LSP.Types
    , module Node.Path
    , parse
    , fromFilePath
    ) where

import LSP.Types
import Node.Path (FilePath)

foreign import parse :: URI -> ParsedURI
foreign import fromFilePath :: FilePath -> URI
