import DSL
import Foundation

public enum CSSValueParseError:
    Error,
    Sendable,
    Equatable
{
    case malformedVariableReference(
        String
    )

    case invalidVariableName(
        String
    )
}

public struct CSSValue:
    Sendable,
    Hashable,
    CustomStringConvertible,
    ExpressibleByStringInterpolation
{
    public struct VariableReference:
        Sendable,
        Hashable
    {
        public let variable:
            AnyCSSVariable

        public let fallback:
            CSSValue?

        public init(
            variable:
                AnyCSSVariable,
            fallback:
                CSSValue? = nil
        ) {
            self.variable =
                variable

            self.fallback =
                fallback
        }

        public var serialized:
            String
        {
            guard
                let fallback
            else {
                return
                    "var(\(variable.rawValue))"
            }

            return
                "var(\(variable.rawValue), \(fallback.serialized))"
        }
    }

    public indirect enum Component:
        Sendable,
        Hashable
    {
        case text(
            String
        )

        case variable(
            VariableReference
        )

        case animation(
            CSSAnimationName
        )
    }

    public struct StringInterpolation:
        StringInterpolationProtocol
    {
        fileprivate var components:
            [Component]

        public init(
            literalCapacity:
                Int,
            interpolationCount:
                Int
        ) {
            self.components =
                []

            self.components
                .reserveCapacity(
                    max(
                        1,
                        interpolationCount * 2 + 1
                    )
                )
        }

        public mutating func appendLiteral(
            _ literal: String
        ) {
            appendText(
                literal
            )
        }

        /// Preserve an interpolated CSS value structurally instead of
        /// serializing it and reparsing it.
        public mutating func appendInterpolation(
            _ value: CSSValue
        ) {
            components.append(
                contentsOf:
                    value.components
            )
        }

        /// Preserve an explicitly typed animation identity when it appears
        /// inside a larger CSS value such as the `animation` shorthand.
        public mutating func appendInterpolation(
            _ animation:
                CSSAnimationName
        ) {
            components.append(
                .animation(
                    animation
                )
            )
        }

        /// Opaque values remain ordinary CSS source text.
        public mutating func appendInterpolation<Value>(
            _ value: Value
        ) {
            appendText(
                String(
                    describing:
                        value
                )
            )
        }

        private mutating func appendText(
            _ text: String
        ) {
            guard
                !text.isEmpty
            else {
                return
            }

            if
                case .text(
                    let existing
                )? =
                    components.last
            {
                components[
                    components.count - 1
                ] =
                    .text(
                        existing + text
                    )
            } else {
                components.append(
                    .text(
                        text
                    )
                )
            }
        }
    }

    public let components:
        [Component]

    public init(
        components:
            [Component]
    ) {
        self.components =
            Self.normalized(
                components
            )
    }

    /// Explicit uninterpreted escape hatch.
    public static func raw(
        _ source: String
    ) -> CSSValue {
        CSSValue(
            components: [
                .text(
                    source
                ),
            ]
        )
    }

    /// Parse the CSS-value syntax we deliberately understand while retaining
    /// all other syntax as textual components.
    ///
    /// At this stage the semantic syntax understood is CSS custom-property
    /// `var(...)` references, including nested fallbacks and references
    /// embedded inside larger values.
    public init(
        parsing source:
            String
    ) throws {
        var parser =
            CSSValueParser(
                source
            )

        self.init(
            components:
                try parser.parse()
        )
    }

    public init(
        stringLiteral value:
            String
    ) {
        if
            let parsed =
                try? CSSValue(
                    parsing:
                        value
                )
        {
            self =
                parsed
        } else {
            self =
                .raw(
                    value
                )
        }
    }

    public init(
        stringInterpolation:
            StringInterpolation
    ) {
        self.init(
            components:
                stringInterpolation
                    .components
        )
    }

    public static func variable(
        _ variable:
            AnyCSSVariable,
        fallback:
            CSSValue? = nil
    ) -> CSSValue {
        CSSValue(
            components: [
                .variable(
                    VariableReference(
                        variable:
                            variable,
                        fallback:
                            fallback
                    )
                ),
            ]
        )
    }

    public static func animation(
        _ animation:
            CSSAnimationName
    ) -> CSSValue {
        CSSValue(
            components: [
                .animation(
                    animation
                ),
            ]
        )
    }

    public var serialized:
        String
    {
        components
            .map { component in
                switch component {
                case .text(
                    let text
                ):
                    return text

                case .variable(
                    let reference
                ):
                    return
                        reference
                            .serialized

                case .animation(
                    let animation
                ):
                    return
                        animation
                            .serialized
                }
            }
            .joined()
    }

    /// Variable references in semantic source order.
    ///
    /// Nested fallback references are retained recursively.
    public var variableReferences:
        [AnyCSSVariable]
    {
        var result:
            [AnyCSSVariable] =
                []

        for component
            in components
        {
            guard
                case .variable(
                    let reference
                ) =
                    component
            else {
                continue
            }

            result.append(
                reference.variable
            )

            if
                let fallback =
                    reference.fallback
            {
                result.append(
                    contentsOf:
                        fallback
                            .variableReferences
                )
            }
        }

        return result
    }

    /// Animation identities explicitly retained by this value.
    ///
    /// Raw CSS text is deliberately not guessed or tokenized for animation
    /// names. Identity exists when the caller supplied semantic identity.
    public var animationReferences:
        [CSSAnimationName]
    {
        var result:
            [CSSAnimationName] =
                []

        for component
            in components
        {
            switch component {
            case .animation(
                let animation
            ):
                result.append(
                    animation
                )

            case .variable(
                let reference
            ):
                if
                    let fallback =
                        reference.fallback
                {
                    result.append(
                        contentsOf:
                            fallback
                                .animationReferences
                    )
                }

            case .text:
                continue
            }
        }

        return result
    }

    public var description:
        String
    {
        serialized
    }

    private static func normalized(
        _ components:
            [Component]
    ) -> [Component] {
        var result:
            [Component] =
                []

        result.reserveCapacity(
            components.count
        )

        for component
            in components
        {
            switch component {
            case .text(
                let text
            ):
                guard
                    !text.isEmpty
                else {
                    continue
                }

                if
                    case .text(
                        let existing
                    )? =
                        result.last
                {
                    result[
                        result.count - 1
                    ] =
                        .text(
                            existing + text
                        )
                } else {
                    result.append(
                        .text(
                            text
                        )
                    )
                }

            case .variable,
                 .animation:
                result.append(
                    component
                )
            }
        }

        return result
    }
}

private struct CSSValueParser {
    private let characters:
        [Character]

    private var index:
        Int =
            0

    init(
        _ source: String
    ) {
        self.characters =
            Array(
                source
            )
    }

    mutating func parse()
        throws -> [CSSValue.Component]
    {
        var components:
            [CSSValue.Component] =
                []

        var text =
            ""

        func flushText(
            _ value:
                inout String,
            into components:
                inout [CSSValue.Component]
        ) {
            guard
                !value.isEmpty
            else {
                return
            }

            components.append(
                .text(
                    value
                )
            )

            value =
                ""
        }

        while
            index
                < characters.count
        {
            let character =
                characters[
                    index
                ]

            if
                character == "\""
                || character == "'"
            {
                copyQuotedText(
                    into:
                        &text
                )

                continue
            }

            if
                startsVariableReference()
            {
                flushText(
                    &text,
                    into:
                        &components
                )

                components.append(
                    .variable(
                        try parseVariableReference()
                    )
                )

                continue
            }

            text.append(
                character
            )

            index += 1
        }

        flushText(
            &text,
            into:
                &components
        )

        return components
    }

    private mutating func copyQuotedText(
        into text:
            inout String
    ) {
        let quote =
            characters[
                index
            ]

        // Consume the opening delimiter separately so it cannot also be
        // mistaken for the closing delimiter.
        text.append(
            quote
        )

        index += 1

        var escaped =
            false

        while
            index
                < characters.count
        {
            let character =
                characters[
                    index
                ]

            text.append(
                character
            )

            index += 1

            if escaped {
                escaped =
                    false

                continue
            }

            if
                character == "\\"
            {
                escaped =
                    true

                continue
            }

            if
                character == quote
            {
                return
            }
        }
    }

    private func startsVariableReference()
        -> Bool
    {
        guard
            index + 3
                < characters.count,
            characters[
                index
            ] == "v",
            characters[
                index + 1
            ] == "a",
            characters[
                index + 2
            ] == "r",
            characters[
                index + 3
            ] == "("
        else {
            return false
        }

        guard
            index > 0
        else {
            return true
        }

        return
            !isNameCharacter(
                characters[
                    index - 1
                ]
            )
    }

    private mutating func parseVariableReference()
        throws -> CSSValue.VariableReference
    {
        let sourceStart =
            index

        index += 4

        var depth =
            1

        var quote:
            Character?

        var escaped =
            false

        var body =
            ""

        while
            index
                < characters.count
        {
            let character =
                characters[
                    index
                ]

            index += 1

            if
                let activeQuote =
                    quote
            {
                body.append(
                    character
                )

                if escaped {
                    escaped =
                        false

                    continue
                }

                if
                    character == "\\"
                {
                    escaped =
                        true

                    continue
                }

                if
                    character
                        == activeQuote
                {
                    quote =
                        nil
                }

                continue
            }

            if
                character == "\""
                || character == "'"
            {
                quote =
                    character

                body.append(
                    character
                )

                continue
            }

            if
                character == "("
            {
                depth += 1

                body.append(
                    character
                )

                continue
            }

            if
                character == ")"
            {
                depth -= 1

                if depth == 0 {
                    break
                }

                body.append(
                    character
                )

                continue
            }

            body.append(
                character
            )
        }

        guard
            depth == 0
        else {
            throw
                CSSValueParseError
                    .malformedVariableReference(
                        String(
                            characters[
                                sourceStart...
                            ]
                        )
                    )
        }

        let arguments =
            splitVariableArguments(
                body
            )

        let name =
            arguments
                .name
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

        guard
            name.hasPrefix(
                "--"
            )
        else {
            throw
                CSSValueParseError
                    .invalidVariableName(
                        name
                    )
        }

        let fallback:
            CSSValue?

        if
            let fallbackSource =
                arguments.fallback
        {
            fallback =
                try CSSValue(
                    parsing:
                        fallbackSource
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )
                )
        } else {
            fallback =
                nil
        }

        return
            CSSValue
                .VariableReference(
                    variable:
                        AnyCSSVariable(
                            name
                        ),
                    fallback:
                        fallback
                )
    }

    private func splitVariableArguments(
        _ source: String
    ) -> (
        name:
            String,
        fallback:
            String?
    ) {
        let values =
            Array(
                source
            )

        var depth =
            0

        var quote:
            Character?

        var escaped =
            false

        for index
            in values.indices
        {
            let character =
                values[
                    index
                ]

            if
                let activeQuote =
                    quote
            {
                if escaped {
                    escaped =
                        false

                    continue
                }

                if
                    character == "\\"
                {
                    escaped =
                        true

                    continue
                }

                if
                    character
                        == activeQuote
                {
                    quote =
                        nil
                }

                continue
            }

            if
                character == "\""
                || character == "'"
            {
                quote =
                    character

                continue
            }

            if
                character == "("
            {
                depth += 1

                continue
            }

            if
                character == ")"
            {
                depth -= 1

                continue
            }

            if
                character == ",",
                depth == 0
            {
                let name =
                    String(
                        values[
                            ..<index
                        ]
                    )

                let fallbackStart =
                    values.index(
                        after:
                            index
                    )

                let fallback =
                    String(
                        values[
                            fallbackStart...
                        ]
                    )

                return (
                    name,
                    fallback
                )
            }
        }

        return (
            source,
            nil
        )
    }

    private func isNameCharacter(
        _ character:
            Character
    ) -> Bool {
        character.isLetter
            || character.isNumber
            || character == "-"
            || character == "_"
    }
}
