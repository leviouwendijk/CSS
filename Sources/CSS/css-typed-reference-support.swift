import DSL

public extension CSSSelector {
    init<Namespace>(
        _ target:
            DOMSelectorTarget<Namespace>
    ) {
        switch target {
        case .id(
            let value
        ):
            self =
                .id(
                    value.erased
                )

        case .class(
            let value
        ):
            self =
                .class(
                    value.erased
                )

        case .raw(
            let value
        ):
            self =
                .raw(
                    value
                )
        }
    }

    static func `class`<Namespace>(
        _ value:
            HTMLClass<Namespace>
    ) -> CSSSelector {
        .class(
            value.erased
        )
    }

    static func id<Namespace>(
        _ value:
            HTMLID<Namespace>
    ) -> CSSSelector {
        .id(
            value.erased
        )
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
        _ property:
            CSSVariable<Namespace>,
        _ value:
            CSSValue
    ) -> CSSDeclaration {
        CSSDeclaration(
            property:
                .custom(
                    property.erased
                ),
            value:
                value
        )
    }

    static func decl(
        _ property:
            AnyCSSVariable,
        _ value:
            CSSValue
    ) -> CSSDeclaration {
        CSSDeclaration(
            property:
                .custom(
                    property
                ),
            value:
                value
        )
    }

    static func variable<Namespace>(
        _ value:
            CSSVariable<Namespace>,
        fallback:
            CSSValue? = nil
    ) -> CSSValue {
        .variable(
            value.erased,
            fallback:
                fallback
        )
    }

    static func variable(
        _ value:
            AnyCSSVariable,
        fallback:
            CSSValue? = nil
    ) -> CSSValue {
        .variable(
            value,
            fallback:
                fallback
        )
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
    _ property:
        CSSVariable<Namespace>,
    _ value:
        CSSValue
) -> CSSDeclaration {
    CSS.decl(
        property,
        value
    )
}

@inlinable
public func decl(
    _ property:
        AnyCSSVariable,
    _ value:
        CSSValue
) -> CSSDeclaration {
    CSS.decl(
        property,
        value
    )
}

@inlinable
public func cssvar<Namespace>(
    _ value:
        CSSVariable<Namespace>,
    fallback:
        CSSValue? = nil
) -> CSSValue {
    CSS.variable(
        value,
        fallback:
            fallback
    )
}

@inlinable
public func cssvar(
    _ value:
        AnyCSSVariable,
    fallback:
        CSSValue? = nil
) -> CSSValue {
    CSS.variable(
        value,
        fallback:
            fallback
    )
}
