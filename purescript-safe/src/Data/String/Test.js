export const stripMargin = (s) => {
    let lines = s.split("\n")

    let m = 10**9
    for (let i = 1; i < lines.length - 1; i += 1) {
        let line = lines[i]
        let mline = 0
        while (line[mline] === ' ')
            mline += 1
        m = Math.min(m, mline)
    }

    let strippedLines = []
    for (let i = 1; i < lines.length - 1; i += 1) {
        let line = lines[i].substring(m)
        strippedLines.push(line)
    }
    return strippedLines.join("\n")
}
