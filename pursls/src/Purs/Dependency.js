const NEWLINE = '\n'
const SPACE = ' '
const isWhitespace = (c) => /\s/.test(c)
const isNonWhitespace = (c) => /\S/.test(c)

export const parseDependency = (s) => {
    let i = 0

    function takeWhile(predicate) {
        while (predicate(s[i])) {
            i += 1
        }
    }

    function match(word) {
        let j = 0
        while (j < word.length) {
            if (s[i+j] === word[j])
                j += 1
            else
                return false
        }
        i += j
        return true
    }

    function line() {
        let j = i
        while (s[j] === SPACE) {
            j += 1
        }
        if (s[j] === NEWLINE) {
            i = j + 1
            return true
        }
        return false
    }

    function parentheses(opening) {
        while (opening > 0) {
            if (s[i] === '(') {
                opening += 1
            }
            else if (s[i] === ')') {
                opening -= 1
            }
            i += 1
        }

    }

    function moduleWhere() {
        takeWhile(isWhitespace)
        match("module")
        takeWhile(isWhitespace)
        let j = i
        takeWhile((c) => isNonWhitespace(c) && c !== '(')
        let moduleName = s.slice(j, i)
        takeWhile(isWhitespace)
        if (s[i] === '(') {
            i += 1
            parentheses(1)
        }
        takeWhile(isWhitespace)
        match("where")
        takeWhile((c) => c !== NEWLINE)
        return moduleName
    }

    function moduleImport() {
        while (line()) {}
        if (match("import ")) {
            takeWhile((x) => x !== NEWLINE)
            return true
        }
        return false
    }

    let moduleName = moduleWhere()
    while (moduleImport()) {}
    let dependencyText = s.slice(0, i)
    return { moduleName, dependencyText }
}
