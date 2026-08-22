import DSL

public enum CSSProperty:
    Sendable,
    Hashable,
    CustomStringConvertible,
    ExpressibleByStringLiteral
{
    /// An ordinary or otherwise uninterpreted CSS property name.
    case raw(
        String
    )

    /// A CSS custom property whose identity remains available structurally.
    case custom(
        AnyCSSVariable
    )

    public init(
        _ source: String
    ) {
        let normalized =
            source
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

        if normalized.hasPrefix(
            "--"
        ) {
            self =
                .custom(
                    AnyCSSVariable(
                        normalized
                    )
                )
        } else {
            self =
                .raw(
                    normalized
                )
        }
    }

    public init(
        stringLiteral value: String
    ) {
        self.init(
            value
        )
    }

    public var serialized: String {
        switch self {
        case .raw(
            let value
        ):
            return value

        case .custom(
            let variable
        ):
            return variable.rawValue
        }
    }

    public var customVariable:
        AnyCSSVariable?
    {
        guard
            case .custom(
                let variable
            ) =
                self
        else {
            return nil
        }

        return variable
    }

    public var description: String {
        serialized
    }
}
