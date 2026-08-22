public struct CSSContributionIdentifier:
    Sendable,
    Hashable,
    CustomStringConvertible,
    ExpressibleByStringLiteral,
    CSSContributionIdentifying
{
    public let rawValue:
        String

    public init(
        _ rawValue:
            String
    ) {
        self.rawValue =
            rawValue
    }

    public init(
        stringLiteral value:
            String
    ) {
        self.init(
            value
        )
    }

    public var cssContributionIdentifier:
        CSSContributionIdentifier
    {
        self
    }

    public var description:
        String
    {
        rawValue
    }
}

/// Authoring identity that can be erased into the heterogeneous CSS
/// contribution graph without erasing the contribution itself to text.
///
/// RawRepresentable String enums can conform directly:
///
///     enum Style: String, CSSContributionIdentifying {
///         case navigation
///     }
public protocol CSSContributionIdentifying:
    Sendable
{
    var cssContributionIdentifier:
        CSSContributionIdentifier
    {
        get
    }
}

public extension CSSContributionIdentifying
where
    Self:
        RawRepresentable,
    Self.RawValue == String
{
    var cssContributionIdentifier:
        CSSContributionIdentifier
    {
        CSSContributionIdentifier(
            rawValue
        )
    }
}
