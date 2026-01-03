// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#window_showMessageRequest
export const window_showWarningMessageWithActions = (conn) => (message) => (actions) => () => {
    return conn.window.showWarningMessage(message, ...actions)
}

export const window_showWarningMessage = (conn) => (message) => () => {
    conn.window.showWarningMessage(message)
}

export const window_showInfoMessage = (conn) => (message) => () => {
    conn.window.showInformationMessage(message)
}

export const window_showErrorMessage = (conn) => (message) => () => {
    conn.window.showErrorMessage(message)
}
