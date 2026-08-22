import Foundation

public struct CSSRule:
    Sendable,
    Equatable,
    CSSNode
{
    public var selector:
        CSSSelector

    public var declarations:
        [CSSDeclaration]

    public init(
        selector:
            CSSSelector,
        declarations:
            [CSSDeclaration]
    ) {
        self.selector =
            selector

        self.declarations =
            declarations
    }

    /// Raw compatibility initializer.
    ///
    /// The selector remains represented as a `CSSSelector`; callers choosing
    /// a string are explicitly entering through its raw escape hatch.
    public init(
        selector:
            String,
        declarations:
            [CSSDeclaration]
    ) {
        self.init(
            selector:
                .raw(
                    selector
                ),
            declarations:
                declarations
        )
    }
}

public typealias CSSRuleMetaSection =
    CSSMetaSection<CSSRule>

extension CSSRuleMetaSection {
    public func customProperties(
        selector:
            String = ":root",
        filter:
            (
                (
                    CSSCustomProperty
                ) -> Bool
            )? = nil
    ) -> [CSSCustomProperty] {
        _extractCustomCSSProperties(
            from:
                items,
            selector:
                selector,
            filter:
                filter
        )
    }
}
