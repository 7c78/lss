export const fromString = (s) => {
    let n = parseFloat(s)
    if (!isFinite(n))
        throw new Error(`Data.Number.Safe.fromString: ${s} is not a number.`)
    return n
}
