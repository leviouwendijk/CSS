import Foundation

public enum CSSKeyframeSelector:
    Sendable,
    Hashable,
    CustomStringConvertible,
    ExpressibleByStringLiteral
{
    case from
    case to

    case percentage(
        Int
    )

    /// Explicit escape hatch for selector syntax outside the structural
    /// subset represented above.
    case raw(
        String
    )

    public init(
        _ source:
            String
    ) {
        let normalized =
            source
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

        switch normalized {
        case "from":
            self =
                .from

        case "to":
            self =
                .to

        default:
            if
                normalized.hasSuffix(
                    "%"
                ),
                let value =
                    Int(
                        normalized
                            .dropLast()
                    ),
                (0...100)
                    .contains(
                        value
                    )
            {
                self =
                    .percentage(
                        value
                    )
            } else {
                self =
                    .raw(
                        normalized
                    )
            }
        }
    }

    public init(
        stringLiteral value:
            String
    ) {
        self.init(
            value
        )
    }

    public var serialized:
        String
    {
        switch self {
        case .from:
            return "from"

        case .to:
            return "to"

        case .percentage(
            let value
        ):
            return
                "\(value)%"

        case .raw(
            let source
        ):
            return source
        }
    }

    public var description:
        String
    {
        serialized
    }
}

public struct CSSKeyframeStep:
    Sendable,
    Hashable,
    CSSNode
{
    public var selector:
        CSSKeyframeSelector

    public var declarations:
        [CSSDeclaration]

    public init(
        selector:
            CSSKeyframeSelector,
        declarations:
            [CSSDeclaration]
    ) {
        self.selector =
            selector

        self.declarations =
            declarations
    }

    /// Raw authoring convenience.
    ///
    /// The string is immediately interpreted into the semantic selector
    /// representation and is not retained as authoritative state.
    public init(
        selector:
            String,
        declarations:
            [CSSDeclaration]
    ) {
        self.init(
            selector:
                CSSKeyframeSelector(
                    selector
                ),
            declarations:
                declarations
        )
    }
}

public struct CSSKeyframes:
    Sendable,
    Hashable,
    CSSNode
{
    public var name:
        CSSAnimationName

    public var steps:
        [CSSKeyframeStep]

    public init(
        name:
            CSSAnimationName,
        steps:
            [CSSKeyframeStep]
    ) {
        self.name =
            name

        self.steps =
            steps
    }

    /// Raw authoring convenience.
    ///
    /// Animation identity becomes structural immediately.
    public init(
        name:
            String,
        steps:
            [CSSKeyframeStep]
    ) {
        self.init(
            name:
                CSSAnimationName(
                    name
                ),
            steps:
                steps
        )
    }
}

public typealias CSSKeyframesMetaSection =
    CSSMetaSection<CSSKeyframes>
