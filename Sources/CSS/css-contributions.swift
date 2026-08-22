import DSL
import Foundation

public enum CSSContributionResolutionError:
    Error,
    Sendable,
    Equatable,
    LocalizedError
{
    case conflicting(
        identifier:
            CSSContributionIdentifier
    )

    public var errorDescription:
        String?
    {
        switch self {
        case .conflicting(
            let identifier
        ):
            return
                "Conflicting CSS contributions share identifier '\(identifier.rawValue)'"
        }
    }
}

/// Unresolved CSS dependency contributions.
///
/// Repeated identities are valid here. Composition is allowed to truthfully
/// contribute the same reusable dependency more than once.
public struct CSSContributions:
    Sendable,
    Equatable
{
    public let contributions:
        [CSSContribution]

    public init(
        _ contributions:
            [CSSContribution]
    ) {
        self.contributions =
            contributions
    }

    public init(
        @CSSContributionsBuilder _ content:
            () -> [CSSContribution]
    ) {
        self.contributions =
            content()
    }

    /// Resolve reusable dependency identity.
    ///
    /// Invariants of the returned value:
    ///
    /// - every contribution identifier occurs exactly once;
    /// - equal repeated contributions are deduplicated;
    /// - conflicting repeated identities fail;
    /// - first semantic occurrence determines stable order;
    /// - contribution content remains rich and uncollected.
    public func resolve()
        throws -> ResolvedCSSContributions
    {
        var resolved:
            [CSSContribution] =
                []

        var indexByIdentifier:
            [
                CSSContributionIdentifier:
                    Int
            ] =
                [:]

        resolved.reserveCapacity(
            contributions.count
        )

        for contribution
            in contributions
        {
            let identifier =
                contribution
                    .identifier

            guard
                let existingIndex =
                    indexByIdentifier[
                        identifier
                    ]
            else {
                indexByIdentifier[
                    identifier
                ] =
                    resolved.count

                resolved.append(
                    contribution
                )

                continue
            }

            let existing =
                resolved[
                    existingIndex
                ]

            guard
                existing.content
                    == contribution.content
            else {
                throw
                    CSSContributionResolutionError
                        .conflicting(
                            identifier:
                                identifier
                        )
            }

            // Equivalent same-identity contribution:
            // preserve the first semantic occurrence.
        }

        return
            ResolvedCSSContributions(
                resolved:
                    resolved
            )
    }
}

/// CSS contributions after identity resolution.
///
/// Construction is intentionally restricted to `CSSContributions.resolve()`
/// so uniqueness and conflict-freedom are structural invariants.
public struct ResolvedCSSContributions:
    Sendable,
    Equatable
{
    public let contributions:
        [CSSContribution]

    fileprivate init(
        resolved contributions:
            [CSSContribution]
    ) {
        self.contributions =
            contributions
    }

    public var identifiers:
        [CSSContributionIdentifier]
    {
        contributions
            .map(
                \.identifier
            )
    }

    public subscript(
        _ identifier:
            CSSContributionIdentifier
    ) -> CSSContribution? {
        contributions
            .first {
                $0.identifier
                    == identifier
            }
    }

    public subscript<
        Identifier:
            CSSContributionIdentifying
    >(
        _ identifier:
            Identifier
    ) -> CSSContribution? {
        self[
            identifier
                .cssContributionIdentifier
        ]
    }

    /// Explicit lowering from resolved dependency identity into a selected
    /// stylesheet.
    ///
    /// Scope remains an independent selection concern. Resolution itself does
    /// not collect or erase the contribution contents.
    public func collected(
        _ selection:
            ScopeSelection
    ) -> CSSStyleSheet {
        CSSContributionCollector
            .collect(
                selection,
                from:
                    contributions
                        .flatMap {
                            $0
                                .content
                                .units
                        }
            )
    }
}

public extension CSS {
    static func contributions(
        @CSSContributionsBuilder _ content:
            () -> [CSSContribution]
    ) -> CSSContributions {
        CSSContributions(
            content
        )
    }
}
