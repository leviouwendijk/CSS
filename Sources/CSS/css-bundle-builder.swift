import DSL

public extension CSS {
    static func bundle<Scope: ScopeIdentifying>(
        _ scope: Scope,
        @CSSBuilder _ content: () -> [CSSContributionUnit]
    ) -> CSSContributionUnit {
        .scoped(
            scope.scope,
            content()
        )
    }

    static func bundle(
        _ scope: ScopeIdentifier,
        @CSSBuilder _ content: () -> [CSSContributionUnit]
    ) -> CSSContributionUnit {
        .scoped(
            scope,
            content()
        )
    }
}
