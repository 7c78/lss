export const charAt = (i) => (s) => {
    if (s[i] == null) {
        throw new Error(`Data.String.Safe.charAt: index ${i} is out of bounds for string ${s}.`)
    }
    return s[i]
}

export const words = (s) => {
    return s.split(" ")
}

export const unwords = (xs) => {
    return xs.join(" ")
}

export const lines = (s) => {
    return s.split("\n")
}

export const unlines = (xs) => {
    return xs.join("\n")
}

export const init = (s) => {
    if (s.length === 0) {
        throw new Error("Data.String.Safe.init: empty")
    }
    return s.slice(0, -1)
}

export const tail = (s) => {
    if (s.length === 0) {
        throw new Error("Data.String.Safe.tail: empty")
    }
    return s.slice(1)
}
