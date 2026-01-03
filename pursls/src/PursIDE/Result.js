export const decode_List_Imports = (List_Imports) => (toMaybe) => (Left) => (Right) => (json) => {
    try {
        return Right(List_Imports({
            moduleName: json.moduleName,
            imports: json.imports.map((x) => ({
                module: x.module,
                qualifier: toMaybe(x.qualifier)
            }))
        }))
    }
    catch {
        Left(json)
    }
}

export const decode_Type = (Type) => (read_DeclarationType) => (toMaybe) => (Left) => (Right) => (json) => {
    try {
        let declarationType = json.declarationType == null
            ? null
            : read_DeclarationType(json.declarationType)
        let definedAt = json.definedAt == null
            ? null
            : decode_SourceSpan(json.definedAt)

        return Right(Type({
            module: json.module,
            identifier: json.identifier,
            type: json.type,
            expandedType: json.expandedType,
            exportedFrom: json.exportedFrom,
            documentation: toMaybe(json.documentation),
            declarationType: toMaybe(declarationType),
            definedAt: toMaybe(definedAt)
        }))
    }
    catch {
        Left(json)
    }
}

export const decode_Rebuild = (Rebuild) => (toMaybe) => (Left) => (Right) => (json) => {
    function suggestion(e) {
        return e.suggestion == null
            ? null
            : {
                replacement: e.suggestion.replacement,
                replaceRange: toMaybe(e.suggestion.replaceRange)
            }
    }

    try {
        return Right(Rebuild(json.map((e) => ({
            message: e.message,
            errorCode: e.errorCode,
            errorLink: e.errorLink,
            filename: toMaybe(e.filename),
            moduleName: toMaybe(e.moduleName),
            position: toMaybe(e.position),
            suggestion: toMaybe(suggestion(e)),
            allSpans: e.allSpans.map(decode_SourceSpan)
        }))))
    }
    catch {
        return Left(json)
    }
}

export const decode_Usages = (Usages) => (Left) => (Right) => (json) => {
    try {
        return Right(Usages(json.map(decode_SourceSpan)))
    }
    catch {
        return Left(json)
    }
}

function decode_SourcePosition(pos) {
    return { line: pos[0], column: pos[1] }
}

function decode_SourceSpan({ name, start, end }) {
    return {
        name,
        start: decode_SourcePosition(start),
        end: decode_SourcePosition(end)
    }
}
