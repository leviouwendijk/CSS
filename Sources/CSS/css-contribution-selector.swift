import DSL

public enum CSSContributionCollector {
    public static func collect(
        _ selection: ScopeSelection,
        from units: [CSSContributionUnit]
    ) -> CSSStyleSheet {
        var rules: [CSSRule] = []
        var media: [CSSMedia] = []
        var keyframes: [CSSKeyframes] = []

        func append(
            _ units: [CSSContributionUnit]
        ) {
            for unit in units {
                switch unit {
                case .block(let block):
                    switch block {
                    case .rule(let rule):
                        rules.append(rule)

                    case .media(let item):
                        media.append(item)

                    case .keyframes(let item):
                        keyframes.append(item)
                    }

                case .scoped(let scope, let nested):
                    guard selection.includes(scope: scope) else {
                        continue
                    }

                    append(nested)
                }
            }
        }

        func appendUnscoped(
            _ units: [CSSContributionUnit]
        ) {
            for unit in units {
                switch unit {
                case .block(let block):
                    switch block {
                    case .rule(let rule):
                        rules.append(rule)

                    case .media(let item):
                        media.append(item)

                    case .keyframes(let item):
                        keyframes.append(item)
                    }

                case .scoped:
                    continue
                }
            }
        }

        switch selection {
        case .unscoped:
            appendUnscoped(units)

        default:
            append(units)
        }

        return CSSStyleSheet(
            rules: rules,
            media: media,
            keyframes: keyframes
        )
    }
}
