@resultBuilder
public enum CSSBuilder {
    // public static func buildBlock(_ parts: [CSSBlock]...) -> [CSSBlock] {
    //     parts.flatMap { $0 }
    // }

    // public static func buildArray(_ parts: [[CSSBlock]]) -> [CSSBlock] {
    //     parts.flatMap { $0 }
    // }

    // public static func buildEither(first: [CSSBlock]) -> [CSSBlock] {
    //     first
    // }

    // public static func buildEither(second: [CSSBlock]) -> [CSSBlock] {
    //     second
    // }

    // public static func buildOptional(_ part: [CSSBlock]?) -> [CSSBlock] {
    //     part ?? []
    // }

    // public static func buildExpression(_ rule: CSSRule) -> [CSSBlock] {
    //     [.rule(rule)]
    // }

    // public static func buildExpression(_ media: CSSMedia) -> [CSSBlock] {
    //     [.media(media)]
    // }

    // public static func buildExpression(_ blocks: [CSSBlock]) -> [CSSBlock] {
    //     blocks
    // }

    // public static func buildExpression(_ keyframes: CSSKeyframes) -> [CSSBlock] {
    //     [.keyframes(keyframes)]
    // }
}

extension CSSBuilder {
    public static func buildBlock(
        _ parts: [CSSContributionUnit]...
    ) -> [CSSContributionUnit] {
        parts.flatMap { $0 }
    }

    public static func buildArray(
        _ parts: [[CSSContributionUnit]]
    ) -> [CSSContributionUnit] {
        parts.flatMap { $0 }
    }

    public static func buildEither(
        first: [CSSContributionUnit]
    ) -> [CSSContributionUnit] {
        first
    }

    public static func buildEither(
        second: [CSSContributionUnit]
    ) -> [CSSContributionUnit] {
        second
    }

    public static func buildOptional(
        _ part: [CSSContributionUnit]?
    ) -> [CSSContributionUnit] {
        part ?? []
    }

    public static func buildExpression(
        _ rule: CSSRule
    ) -> [CSSContributionUnit] {
        [.block(.rule(rule))]
    }

    public static func buildExpression(
        _ media: CSSMedia
    ) -> [CSSContributionUnit] {
        [.block(.media(media))]
    }

    public static func buildExpression(
        _ keyframes: CSSKeyframes
    ) -> [CSSContributionUnit] {
        [.block(.keyframes(keyframes))]
    }

    public static func buildExpression(
        _ unit: CSSContributionUnit
    ) -> [CSSContributionUnit] {
        [unit]
    }

    public static func buildExpression(
        _ units: [CSSContributionUnit]
    ) -> [CSSContributionUnit] {
        units
    }

    // Compatibility
    public static func buildExpression(
        _ block: CSSBlock
    ) -> [CSSContributionUnit] {
        [.block(block)]
    }

    public static func buildExpression(
        _ blocks: [CSSBlock]
    ) -> [CSSContributionUnit] {
        blocks.map(CSSContributionUnit.block)
    }
}
