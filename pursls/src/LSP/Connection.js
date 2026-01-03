import lsp from "vscode-languageserver"

export { _new as new }
const _new = () => {
    let conn = lsp.createConnection()
    conn.listen()
    conn.onInitialize(() => {
        return {
            // https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#serverCapabilities
            capabilities: {
                hoverProvider: true,
                definitionProvider: true,
                referencesProvider: true
            }
        }
    })
    return conn
}
