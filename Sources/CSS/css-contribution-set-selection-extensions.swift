import DSL

public extension CSSContributionSet {
    func selecting(
        _ selection: ScopeSelection
    ) -> CSSStyleSheet {
        collected(selection)
    }

    func scoped<Scope: ScopeIdentifying>(
        _ scope: Scope
    ) -> CSSStyleSheet {
        collected(.scoped(scope.scope))
    }

    func scoped(
        _ scope: ScopeIdentifier
    ) -> CSSStyleSheet {
        collected(.scoped(scope))
    }

    var unscoped: CSSStyleSheet {
        collected(.unscoped)
    }

    func excluding<Scope: ScopeIdentifying>(
        _ scopes: [Scope]
    ) -> CSSStyleSheet {
        collected(
            .excluding(
                Set(scopes.map(\.scope))
            )
        )
    }

    func excluding(
        _ scopes: Set<ScopeIdentifier>
    ) -> CSSStyleSheet {
        collected(.excluding(scopes))
    }
}
