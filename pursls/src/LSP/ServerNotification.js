// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_publishDiagnostics
export const textDocument_publishDiagnostics = (conn) => (params) => () => {
    conn.sendDiagnostics(params)
}
