import { TextDocuments } from "vscode-languageserver"
import { TextDocument } from "vscode-languageserver-textdocument"

export { _new as new }
const _new = (conn) => () => {
    let docs = new TextDocuments(TextDocument)
    docs.listen(conn)
    return docs
}

export const _get = (docs) => (uri) => () => {
    return docs.get(uri)
}

export const _all = (docs) => () => {
    return docs.all()
}
