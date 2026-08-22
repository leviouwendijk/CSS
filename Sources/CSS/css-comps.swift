import Foundation

public enum CSS {
    // Declarations
    public static func decl(
        _ property: CSSProperty,
        _ value: CSSValue
    ) -> CSSDeclaration {
        CSSDeclaration(
            property:
                property,
            value:
                value
        )
    }

    /// Raw property-name convenience.
    ///
    /// `String` is only the authoring boundary. The declaration immediately
    /// retains `CSSProperty` and `CSSValue` as its authoritative state.
    public static func decl(
        _ property: String,
        _ value: CSSValue
    ) -> CSSDeclaration {
        decl(
            CSSProperty(
                property
            ),
            value
        )
    }

    // Rules (raw selector convenience)
    public static func rule(_ selector: String, _ declarations: [CSSDeclaration]) -> CSSRule {
        CSSRule(selector: selector, declarations: declarations)
    }

    public static func rule(_ selector: String, _ declarations: CSSDeclaration...) -> CSSRule {
        CSSRule(selector: selector, declarations: declarations)
    }

    // Rules (selector-based)
    public static func rule(_ selector: CSSSelector, _ declarations: [CSSDeclaration]) -> CSSRule {
        CSSRule(selector: selector, declarations: declarations)
    }

    public static func rule(_ selector: CSSSelector, _ declarations: CSSDeclaration...) -> CSSRule {
        CSSRule(selector: selector, declarations: declarations)
    }

    // Media
    public static func media(_ query: String, _ rules: [CSSRule]) -> CSSMedia {
        CSSMedia(query: query, rules: rules)
    }

    public static func media(_ query: String, _ rules: CSSRule...) -> CSSMedia {
        CSSMedia(query: query, rules: rules)
    }

    public static func inline(
        _ declarations: [CSSDeclaration]
    ) -> String {
        declarations
            .map(
                \.serialized
            )
            .joined(
                separator:
                    " "
            )
    }

    public static func inline(_ declarations: CSSDeclaration...) -> String {
        inline(declarations)
    }

    // MARK: - Keyframes

    @resultBuilder
    public enum CSSKeyframeStepBuilder {
        public static func buildBlock(_ parts: [CSSKeyframeStep]...) -> [CSSKeyframeStep] {
            parts.flatMap { $0 }
        }

        public static func buildArray(_ parts: [[CSSKeyframeStep]]) -> [CSSKeyframeStep] {
            parts.flatMap { $0 }
        }

        public static func buildEither(first: [CSSKeyframeStep]) -> [CSSKeyframeStep] {
            first
        }

        public static func buildEither(second: [CSSKeyframeStep]) -> [CSSKeyframeStep] {
            second
        }

        public static func buildOptional(_ part: [CSSKeyframeStep]?) -> [CSSKeyframeStep] {
            part ?? []
        }

        public static func buildExpression(_ step: CSSKeyframeStep) -> [CSSKeyframeStep] {
            [step]
        }

        public static func buildExpression(_ steps: [CSSKeyframeStep]) -> [CSSKeyframeStep] {
            steps
        }
    }

    public static func keyframes(
        _ name:
            CSSAnimationName,
        @CSSKeyframeStepBuilder _ steps:
            () -> [CSSKeyframeStep]
    ) -> CSSKeyframes {
        CSSKeyframes(
            name:
                name,
            steps:
                steps()
        )
    }

    /// String convenience for ordinary authoring.
    ///
    /// The resulting keyframe block retains `CSSAnimationName`.
    public static func keyframes(
        _ name:
            String,
        @CSSKeyframeStepBuilder _ steps:
            () -> [CSSKeyframeStep]
    ) -> CSSKeyframes {
        keyframes(
            CSSAnimationName(
                name
            ),
            steps
        )
    }

    public static func step(
        _ selector:
            CSSKeyframeSelector,
        _ declarations:
            [CSSDeclaration]
    ) -> CSSKeyframeStep {
        CSSKeyframeStep(
            selector:
                selector,
            declarations:
                declarations
        )
    }

    public static func step(
        _ selector:
            CSSKeyframeSelector,
        @CSSDeclBuilder _ declarations:
            () -> [CSSDeclaration]
    ) -> CSSKeyframeStep {
        CSSKeyframeStep(
            selector:
                selector,
            declarations:
                declarations()
        )
    }

    /// String convenience that immediately becomes a semantic selector.
    public static func step(
        _ selector:
            String,
        _ declarations:
            [CSSDeclaration]
    ) -> CSSKeyframeStep {
        step(
            CSSKeyframeSelector(
                selector
            ),
            declarations
        )
    }

    public static func step(
        _ selector:
            String,
        @CSSDeclBuilder _ declarations:
            () -> [CSSDeclaration]
    ) -> CSSKeyframeStep {
        step(
            CSSKeyframeSelector(
                selector
            ),
            declarations
        )
    }

    public static func from(
        @CSSDeclBuilder _ declarations:
            () -> [CSSDeclaration]
    ) -> CSSKeyframeStep {
        step(
            .from,
            declarations
        )
    }

    public static func to(
        @CSSDeclBuilder _ declarations:
            () -> [CSSDeclaration]
    ) -> CSSKeyframeStep {
        step(
            .to,
            declarations
        )
    }

    public static func pct(
        _ value:
            Int,
        @CSSDeclBuilder _ declarations:
            () -> [CSSDeclaration]
    ) -> CSSKeyframeStep {
        step(
            .percentage(
                value
            ),
            declarations
        )
    }

    /// Semantic animation-name reference suitable for declarations.
    public static func animation(
        _ name:
            CSSAnimationName
    ) -> CSSValue {
        .animation(
            name
        )
    }

}

public extension CSS {
    static func stylesheet(
        @CSSBuilder _ content: () -> [CSSContributionUnit]
    ) -> CSSContributionSet {
        CSSContributionSet(content)
    }
}
