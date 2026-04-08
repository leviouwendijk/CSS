import DSL

public struct CSSContributionSet: Sendable, Equatable {
    public let units: [CSSContributionUnit]

    public init(
        units: [CSSContributionUnit]
    ) {
        self.units = units
    }

    public init(
        @CSSBuilder _ content: () -> [CSSContributionUnit]
    ) {
        self.units = content()
    }

    public func collected(
        _ selection: ScopeSelection
    ) -> CSSStyleSheet {
        CSSContributionCollector.collect(
            selection,
            from: units
        )
    }

    public var sheet: CSSStyleSheet {
        collected(.all)
    }
}
