import DSL

public extension CSSSelector {
    init<Namespace>(
        _ target: DOMSelectorTarget<Namespace>
    ) {
        self.init(target.rawValue)
    }

    static func `class`<Namespace>(
        _ value: HTMLClass<Namespace>
    ) -> CSSSelector {
        CSSSelector(".\(value.rawValue)")
    }

    static func id<Namespace>(
        _ value: HTMLID<Namespace>
    ) -> CSSSelector {
        CSSSelector("#\(value.rawValue)")
    }
}

public extension CSS {
    static func rule<Namespace>(
        _ selector: DOMSelectorTarget<Namespace>,
        _ declarations: [CSSDeclaration]
    ) -> CSSRule {
        rule(CSSSelector(selector), declarations)
    }

    static func rule<Namespace>(
        _ selector: DOMSelectorTarget<Namespace>,
        _ declarations: CSSDeclaration...
    ) -> CSSRule {
        rule(CSSSelector(selector), declarations)
    }

    static func decl<Namespace>(
        _ property: CSSVariable<Namespace>,
        _ value: String
    ) -> CSSDeclaration {
        CSSDeclaration(
            property: property.rawValue,
            value: value
        )
    }

    static func variable<Namespace>(
        _ value: CSSVariable<Namespace>
    ) -> String {
        "var(\(value.rawValue))"
    }
}

@inlinable
public func rule<Namespace>(
    _ selector: DOMSelectorTarget<Namespace>,
    _ declarations: [CSSDeclaration]
) -> CSSRule {
    CSS.rule(selector, declarations)
}

@inlinable
public func rule<Namespace>(
    _ selector: DOMSelectorTarget<Namespace>,
    _ declarations: CSSDeclaration...
) -> CSSRule {
    CSS.rule(selector, declarations)
}

@inlinable
public func decl<Namespace>(
    _ property: CSSVariable<Namespace>,
    _ value: String
) -> CSSDeclaration {
    CSS.decl(property, value)
}

@inlinable
public func cssvar<Namespace>(
    _ value: CSSVariable<Namespace>
) -> String {
    CSS.variable(value)
}
