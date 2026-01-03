import { URI } from "vscode-uri"

export const parse = (uri) => {
    let parsed = URI.parse(uri)
    return {
        fsPath: parsed.fsPath,
        scheme: parsed.scheme
    }
}

export const fromFilePath = (path) => {
    return URI.file(path).toString()
}
