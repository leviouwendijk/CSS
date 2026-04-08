import DSL

public struct CSSBundledSheet: Sendable, Equatable {
    public let scope: ScopeIdentifier
    public let sheet: CSSStyleSheet

    public init(
        scope: ScopeIdentifier,
        sheet: CSSStyleSheet
    ) {
        self.scope = scope
        self.sheet = sheet
    }
}

@inlinable
public func bundle<Scope: ScopeIdentifying>(
    _ scope: Scope,
    _ sheet: CSSStyleSheet
) -> CSSBundledSheet {
    CSSBundledSheet(
        scope: scope.scope_id,
        sheet: sheet
    )
}

@inlinable
public func bundle(
    _ scope: ScopeIdentifier,
    _ sheet: CSSStyleSheet
) -> CSSBundledSheet {
    CSSBundledSheet(
        scope: scope,
        sheet: sheet
    )
}
