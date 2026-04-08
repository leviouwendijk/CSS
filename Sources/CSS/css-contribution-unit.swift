import DSL

public enum CSSContributionUnit: Sendable, Equatable {
    case block(CSSBlock)
    case scoped(ScopeIdentifier, [CSSContributionUnit])
}
