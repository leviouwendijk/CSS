public struct CSSContribution:
    Sendable,
    Equatable
{
    public let identifier:
        CSSContributionIdentifier

    /// Rich CSS contribution structure.
    ///
    /// Scope information and CSS-domain semantics remain intact here.
    /// This is deliberately not a pre-collected `CSSStyleSheet`.
    public let content:
        CSSContributionSet

    public init(
        identifier:
            CSSContributionIdentifier,
        content:
            CSSContributionSet
    ) {
        self.identifier =
            identifier

        self.content =
            content
    }
}

public extension CSS {
    static func contribution<
        Identifier:
            CSSContributionIdentifying
    >(
        _ identifier:
            Identifier,
        @CSSBuilder _ content:
            () -> [CSSContributionUnit]
    ) -> CSSContribution {
        CSSContribution(
            identifier:
                identifier
                    .cssContributionIdentifier,
            content:
                CSSContributionSet(
                    units:
                        content()
                )
        )
    }

    static func contribution(
        _ identifier:
            CSSContributionIdentifier,
        content:
            CSSContributionSet
    ) -> CSSContribution {
        CSSContribution(
            identifier:
                identifier,
            content:
                content
        )
    }
}
