// https://github.com/microsoft/vscode-languageserver-node/blob/ec4504dea3fe958954576d61dd5e558a592dbce2/server/src/common/server.ts#L1137
export const textDocument_didSave = (docs) => (handler) => () => {
    docs.onDidSave((params) => handler(params)())
}

export const textDocument_didOpen = (docs) => (handler) => () => {
    docs.onDidOpen((params) => handler(params)())
}
