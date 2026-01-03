export const _getTextAtRange = (range) => (doc) => () => {
    return doc.getText(range)
}

export const _getText = (doc) => () => {
    return doc.getText()
}
