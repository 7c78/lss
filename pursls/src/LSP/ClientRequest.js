const requestHandler = (register) => (handler) => () => {
    register((args) => handler(args)())
}

const requestHandler0 = (register) => (handler) => () => {
    register(handler)
}

export const shutdown = (conn) => requestHandler0(conn.onShutdown)
export const textDocument_hover = (conn) => requestHandler(conn.onHover)
export const textDocument_definition = (conn) => requestHandler(conn.onDefinition)
export const textDocument_references = (conn) => requestHandler(conn.onReferences)
