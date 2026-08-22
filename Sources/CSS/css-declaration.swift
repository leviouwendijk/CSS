import Foundation

public enum CSSDeclarationParseError:
    Error,
    Sendable,
    Equatable
{
    case missingPropertyValueSeparator(
        String
    )

    case missingProperty(
        String
    )
}

public struct CSSDeclaration:
    Sendable,
    Hashable,
    CustomStringConvertible
{
    public let property:
        CSSProperty

    public let value:
        CSSValue

    public init(
        property:
            CSSProperty,
        value:
            CSSValue
    ) {
        self.property =
            property

        self.value =
            value
    }

    public init(
        parsing source:
            String
    ) throws {
        var normalized =
            source
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

        if
            normalized.hasSuffix(
                ";"
            )
        {
            normalized.removeLast()

            normalized =
                normalized
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
        }

        guard
            let separator =
                normalized
                    .firstIndex(
                        of:
                            ":"
                    )
        else {
            throw
                CSSDeclarationParseError
                    .missingPropertyValueSeparator(
                        source
                    )
        }

        let propertySource =
            String(
                normalized[
                    ..<separator
                ]
            )
            .trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        guard
            !propertySource.isEmpty
        else {
            throw
                CSSDeclarationParseError
                    .missingProperty(
                        source
                    )
        }

        let valueStart =
            normalized
                .index(
                    after:
                        separator
                )

        let valueSource =
            String(
                normalized[
                    valueStart...
                ]
            )
            .trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        self.init(
            property:
                CSSProperty(
                    propertySource
                ),
            value:
                try CSSValue(
                    parsing:
                        valueSource
                )
        )
    }

    public var serialized:
        String
    {
        "\(property.serialized): \(value.serialized);"
    }

    public var description:
        String
    {
        serialized
    }
}
