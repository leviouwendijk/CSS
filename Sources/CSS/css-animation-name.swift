public struct CSSAnimationName:
    Sendable,
    Hashable,
    CustomStringConvertible,
    ExpressibleByStringLiteral
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

    public var serialized:
        String
    {
        rawValue
    }

    public var description:
        String
    {
        serialized
    }
}
