export const _new = () => {
    return new Map()
}

export const _fromArray = (assocs) => () => {
    let m = new Map()
    for (let t of assocs) {
        let k = t.value0
        let v = t.value1
        m.set(k, v)
    }
    return m
}

export const _set = (k) => (v) => (m) => () => {
    m.set(k, v)
}

export const _delete = (k) => (m) => () => {
    m.delete(k)
}

export const _lookup = (Nothing) => (Just) => (k) => (m) => () => {
    return m.has(k) ? Just(m.get(k)) : Nothing
}

export const _lookupUnsafe = (k) => (m) => () => {
    if (!m.has(k)) {
        throw new Error(`Data.Map.MMap.lookupUnsafe: key ${k} does not exist.`)
    }
    return m.get(k)
}
