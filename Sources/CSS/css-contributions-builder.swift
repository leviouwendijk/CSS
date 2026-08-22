@resultBuilder
public enum CSSContributionsBuilder {
    public static func buildBlock(
        _ parts:
            [CSSContribution]...
    ) -> [CSSContribution] {
        parts
            .flatMap {
                $0
            }
    }

    public static func buildExpression(
        _ contribution:
            CSSContribution
    ) -> [CSSContribution] {
        [
            contribution,
        ]
    }

    public static func buildExpression(
        _ contributions:
            [CSSContribution]
    ) -> [CSSContribution] {
        contributions
    }

    public static func buildExpression(
        _ contributions:
            CSSContributions
    ) -> [CSSContribution] {
        contributions
            .contributions
    }

    public static func buildOptional(
        _ part:
            [CSSContribution]?
    ) -> [CSSContribution] {
        part
            ?? []
    }

    public static func buildEither(
        first:
            [CSSContribution]
    ) -> [CSSContribution] {
        first
    }

    public static func buildEither(
        second:
            [CSSContribution]
    ) -> [CSSContribution] {
        second
    }

    public static func buildArray(
        _ parts:
            [[CSSContribution]]
    ) -> [CSSContribution] {
        parts
            .flatMap {
                $0
            }
    }
}
