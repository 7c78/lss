module LSP.Types where

import Node.Path (FilePath)

foreign import data Connection :: Type

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_hover
type HoverParams = TextDocumentPositionParams

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#definitionParams
type DefinitionParams = TextDocumentPositionParams

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#referenceParams
type ReferenceParams = TextDocumentPositionParams

type TextDocumentPositionParams =
    { textDocument :: TextDocumentIdentifier
    , position     :: Position
    }

type TextDocumentIdentifier =
    { uri :: URI
    }

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_symbol
type WorkspaceSymbolParams =
    { query :: String
    }

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#hover
newtype Hover = Hover
    { contents :: MarkupContent
    , range    :: Range
    }

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#location
newtype Location = Location
    { uri   :: URI
    , range :: Range
    }

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#locationLink
newtype LocationLink = LocationLink
    { originSelectionRange :: Range
    , targetUri            :: URI
    , targetRange          :: Range
    , targetSelectionRange :: Range
    }

type MarkupContent =
    { kind  :: String
    , value :: String
    }

type Range =
    { start :: Position
    , end   :: Position
    }

type Position =
    { line      :: Int
    , character :: Int
    }

type URI = String

type ParsedURI =
    { fsPath :: FilePath
    , scheme :: String
    }

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#diagnostic
newtype Diagnostic = Diagnostic
    { range    :: Range
    , severity :: Int    -- 1 (Error) - 2 (Warning) - 3 (Information) - 4 (Hint)
    , message  :: String
    , source   :: String
    , code     :: String -- Int | String
    }

type PublishDiagnosticParams =
    { uri         :: URI
    , diagnostics :: Array Diagnostic
    }

type TextDocument =
    { uri :: URI
    }

foreign import data TextDocuments :: Type

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#messageActionItem
type MessageActionItem =
    { title :: String
    }

-- https://github.com/microsoft/vscode-languageserver-node/blob/ec4504dea3fe958954576d61dd5e558a592dbce2/server/src/common/textDocuments.ts#L37
type TextDocumentChangeEvent =
    { document :: TextDocument
    }

markdownContent :: String -> MarkupContent
markdownContent s = { kind: "markdown", value: s }
