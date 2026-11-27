import DSL

/// A `Theme` lowered to CSS custom properties. Each role's tokens become
/// `--<prefix>-<role>-<token>` on `:root`; the dark scheme overrides them
/// under `prefers-color-scheme: dark` unless the page sets
/// `data-theme="light"`, and always under `data-theme="dark"`.
public enum CSSTheme {
    public enum Token:
        String,
        Sendable,
        Hashable,
        CaseIterable
    {
        case foreground = "fg"
        case background = "bg"
        case weight
        case style
        case decoration
        case spacing
        case indent
    }

    /// The custom property a component reads for `role`'s `token`.
    public static func variable(
        _ role: Theme.Role,
        _ token: Token,
        prefix: String = "theme"
    ) -> AnyCSSVariable {
        AnyCSSVariable(
            "--" + name(prefix) + "-" + name(role.rawValue) + "-" + token.rawValue
        )
    }

    /// `var(--prefix-role-token, fallback)`.
    public static func value(
        _ role: Theme.Role,
        _ token: Token,
        fallback: CSSValue? = nil,
        prefix: String = "theme"
    ) -> CSSValue {
        .variable(
            variable(
                role,
                token,
                prefix: prefix
            ),
            fallback: fallback
        )
    }

    public static func styleSheet(
        _ theme: Theme,
        prefix: String = "theme"
    ) -> CSSStyleSheet {
        let light = declarations(
            theme.light,
            prefix: prefix
        )
        let dark = declarations(
            theme.dark,
            prefix: prefix
        )

        guard !dark.isEmpty else {
            return .init(
                rules: [
                    .init(selector: .raw(":root"), declarations: light),
                ]
            )
        }

        return .init(
            rules: [
                .init(selector: .raw(":root"), declarations: light),
                .init(selector: .raw(":root[data-theme=\"dark\"]"), declarations: dark),
            ],
            media: [
                .init(
                    query: "(prefers-color-scheme: dark)",
                    rules: [
                        .init(selector: .raw(":root:not([data-theme=\"light\"])"), declarations: dark),
                    ]
                ),
            ]
        )
    }

    /// One declaration per token a style sets, roles in name order.
    public static func declarations(
        _ styles: [Theme.Role: Theme.Style],
        prefix: String = "theme"
    ) -> [CSSDeclaration] {
        styles
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .flatMap { role, style in
                tokens(style).map { token, value in
                    CSSDeclaration(
                        property: .custom(
                            variable(
                                role,
                                token,
                                prefix: prefix
                            )
                        ),
                        value: .raw(value)
                    )
                }
            }
    }

    public static func tokens(
        _ style: Theme.Style
    ) -> [(Token, String)] {
        var tokens: [(Token, String)] = []

        if let foreground = style.foreground {
            tokens.append((.foreground, foreground.hex))
        }
        if let background = style.background {
            tokens.append((.background, background.hex))
        }
        if let weight = style.weight {
            let value: String
            switch weight {
            case .light: value = "300"
            case .regular: value = "400"
            case .bold: value = "700"
            }
            tokens.append((.weight, value))
        }
        if let italic = style.italic {
            tokens.append((.style, italic ? "italic" : "normal"))
        }
        if let underline = style.underline {
            tokens.append((.decoration, underline ? "underline" : "none"))
        }
        if let spacing = style.spacing {
            tokens.append((.spacing, "\(spacing)lh"))
        }
        if let indent = style.indent {
            tokens.append((.indent, "\(indent)ch"))
        }

        return tokens
    }

    /// Lowercase letters, digits and `-`; anything else (`.` in
    /// `markdown.heading.1`) becomes `-`.
    private static func name(
        _ raw: String
    ) -> String {
        String(
            raw.lowercased().map { character in
                character.isLetter && character.isASCII
                    || character.isNumber && character.isASCII
                    || character == "-"
                    ? character
                    : "-"
            }
        )
    }
}
