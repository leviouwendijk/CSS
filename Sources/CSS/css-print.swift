public extension CSS {
    static func print(
        _ rules: [CSSRule]
    ) -> CSSMedia {
        CSS.media(
            "print",
            rules
        )
    }

    static func print(
        _ rules: CSSRule...
    ) -> CSSMedia {
        CSS.media(
            "print",
            rules
        )
    }
}
