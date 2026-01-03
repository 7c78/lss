export const trace = (tag) => (x) => {
    console.log(tag, _inspect(x))
}

export const inspect = (x) => {
    return _inspect(x)
}

const _inspect = (obj, opts = {}) => {
    const {
        depth = 3,
        indent = "    ",
        maxArrayLength = 100
    } = opts

    let seen = new WeakSet()

    function pad(level) {
        return indent.repeat(level)
    }

    function format(val, currentDepth) {
        if (val === null) {
            return "null"
        }
        if (val === undefined) {
            return "undefined"
        }
        if (typeof val === "number") {
            return String(val)
        }
        if (typeof val === "boolean") {
            return String(val)
        }
        if (typeof val === "string") {
            return JSON.stringify(val)
                    .replace(/\\"/g, '"')
        }
        if (typeof val === "function") {
            let name = val.name ? `${val.name}` : "(anonymous)"
            return `[Function ${name}]`
        }
        if (val instanceof RegExp) {
            return String(val)
        }
        if (val instanceof Date) {
            return val.toISOString()
        }
        if (val instanceof Error) {
            return `[${val.name}: ${val.message}]`
        }

        if (typeof val === "object") {
            if (seen.has(val)) {
                return "[Circular]"
            }

            seen.add(val)

            if (currentDepth > depth) {
                return "[Object]"
            }

            let padding = pad(currentDepth)
            let innerPadding = pad(currentDepth + 1)

            if (Array.isArray(val)) {
                if (val.length === 0) {
                    return "[]"
                }

                let items = val
                        .slice(0, maxArrayLength)
                        .map((e) => format(e, currentDepth + 1))
                if (val.length > maxArrayLength) {
                    items.push(`... ${val.length - maxArrayLength} more items`)
                }
                return `[\n${innerPadding}${items.join("\n" + innerPadding)}\n${padding}]`
            }

            if (val instanceof Map) {
                if (val.size === 0) {
                    return "Map(0) {}"
                }

                let items = Array.from(val.entries())
                        .slice(0, maxArrayLength)
                        .map(([k, v]) => `${format(k, currentDepth + 1)} => ${format(v, currentDepth + 1)}`)
                return `Map(${val.size}) {\n${innerPadding}${items.join("\n" + innerPadding)}\n${padding}}`
            }

            if (val instanceof Set) {
                if (val.size === 0) {
                    return "Set(0) {}"
                }

                let items = Array.from(val)
                        .slice(0, maxArrayLength)
                        .map((e) => format(e, currentDepth + 1))
                return `Set(${val.size}) {\n${innerPadding}${items.join("\n" + innerPadding)}\n${padding}}`
            }

            // Plain object / class instance
            let ctor = val.constructor != null && val.constructor !== Object
                    ? val.constructor.name + " "
                    : ""
            let keys = Object.keys(val)
            if (keys.length === 0) {
                return `${ctor}{}`
            }
            let entries = keys.map((k) => `${k}: ${format(val[k], currentDepth + 1)}`)
            return `${ctor}{\n${innerPadding}${entries.join("\n" + innerPadding)}\n${padding}}`
        }
    }

    return format(obj, 0)
}
