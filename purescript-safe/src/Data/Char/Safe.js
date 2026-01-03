export const toUpper = (c) => {
    if (c.length !== 1) {
        throw new Error("Data.Char.Safe.toUpper")
    }
    return c.toUpperCase()
}

export const toLower = (c) => {
    if (c.length !== 1) {
        throw new Error("Data.Char.Safe.toLower")
    }
    return c.toLowerCase()
}

export const isDigit = (c) => {
    if (c.length !== 1) {
        throw new Error("Data.Char.Safe.isDigit")
    }
    return c >= "0" && c <= "9"
}

export const isUpper = (c) => {
    if (c.length !== 1) {
        throw new Error("Data.Char.Safe.isUpper")
    }
    return !isDigit(c) && c.toUpperCase() === c
}

export const isLower = (c) => {
    if (c.length !== 1) {
        throw new Error("Data.Char.Safe.isLower")
    }
    return !isDigit(c) && c.toLowerCase() === c
}

export const isAlpha = (c) => {
    if (c.length !== 1) {
        throw new Error("Data.Char.Safe.isAlpha")
    }
    return c.toLowerCase() !== c.toUpperCase()
}

export const isAlphaNum = (c) => {
    if (c.length !== 1) {
        throw new Error("Data.Char.Safe.isAlphaNum")
    }
    return isDigit(c) || isAlpha(c)
}
