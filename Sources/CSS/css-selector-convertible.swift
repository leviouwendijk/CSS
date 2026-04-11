import DSL

public protocol CSSSelectorConvertible: Sendable {
    var cssSelector: CSSSelector { get }
}

extension CSSSelector: CSSSelectorConvertible {
    public var cssSelector: CSSSelector {
        self
    }
}

extension AnyHTMLClass: CSSSelectorConvertible {
    public var cssSelector: CSSSelector {
        .class(rawValue)
    }
}

extension AnyHTMLID: CSSSelectorConvertible {
    public var cssSelector: CSSSelector {
        .id(rawValue)
    }
}

extension HTMLClass: CSSSelectorConvertible {
    public var cssSelector: CSSSelector {
        .class(rawValue)
    }
}

extension HTMLID: CSSSelectorConvertible {
    public var cssSelector: CSSSelector {
        .id(rawValue)
    }
}

extension DOMSelectorTarget: CSSSelectorConvertible {
    public var cssSelector: CSSSelector {
        CSSSelector(self)
    }
}

public extension CSSSelectorConvertible {
    func pseudoClass(
        _ name: String
    ) -> CSSSelector {
        cssSelector.pseudoClass(name)
    }

    func pseudoElement(
        _ name: String
    ) -> CSSSelector {
        cssSelector.pseudoElement(name)
    }

    func descendant(
        _ other: any CSSSelectorConvertible
    ) -> CSSSelector {
        cssSelector.descendant(other.cssSelector)
    }

    func child(
        _ other: any CSSSelectorConvertible
    ) -> CSSSelector {
        cssSelector.child(other.cssSelector)
    }

    func adjacentSibling(
        _ other: any CSSSelectorConvertible
    ) -> CSSSelector {
        cssSelector.adjacentSibling(other.cssSelector)
    }

    func generalSibling(
        _ other: any CSSSelectorConvertible
    ) -> CSSSelector {
        cssSelector.generalSibling(other.cssSelector)
    }

    func compound(
        _ other: any CSSSelectorConvertible
    ) -> CSSSelector {
        CSSSelector(
            "\(cssSelector.raw)\(other.cssSelector.raw)"
        )
    }
}

public extension CSSSelector {
    static func group(
        _ selectors: [any CSSSelectorConvertible]
    ) -> CSSSelector {
        CSSSelector(
            selectors
                .map(\.cssSelector.raw)
                .joined(separator: ", ")
        )
    }

    static func group(
        _ selectors: any CSSSelectorConvertible...
    ) -> CSSSelector {
        group(selectors)
    }
}

public extension CSS {
    static func rule<Selector: CSSSelectorConvertible>(
        _ selector: Selector,
        _ declarations: [CSSDeclaration]
    ) -> CSSRule {
        rule(selector.cssSelector, declarations)
    }

    static func rule<Selector: CSSSelectorConvertible>(
        _ selector: Selector,
        _ declarations: CSSDeclaration...
    ) -> CSSRule {
        rule(selector.cssSelector, declarations)
    }
}
