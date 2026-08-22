import DSL
import Foundation

public struct CSSSelector:
    Sendable,
    Hashable,
    CustomStringConvertible
{
    public enum Combinator:
        Sendable,
        Hashable
    {
        public enum Sibling:
            Sendable,
            Hashable
        {
            case adjacent
            case general
        }

        case descendant
        case child

        case sibling(
            Sibling
        )
    }

    public enum Simple:
        Sendable,
        Hashable
    {
        case element(String)
        case universal
        case `class`(AnyHTMLClass)
        case id(AnyHTMLID)
        case pseudoClass(String)
        case pseudoElement(String)
    }

    public struct Compound:
        Sendable,
        Hashable
    {
        public let selectors: [Simple]

        init(
            selectors: [Simple]
        ) {
            self.selectors =
                selectors
        }
    }

    public struct Sequence:
        Sendable,
        Hashable
    {
        public let compounds: [Compound]
        public let combinators: [Combinator]

        init(
            compounds: [Compound],
            combinators: [Combinator]
        ) {
            self.compounds =
                compounds

            self.combinators =
                combinators
        }
    }

    public enum Representation:
        Sendable,
        Hashable
    {
        case structured(
            [Sequence]
        )

        case raw(
            String
        )
    }

    public struct SymbolGroup:
        Sendable,
        Equatable
    {
        public let classes:
            Set<AnyHTMLClass>

        public let ids:
            Set<AnyHTMLID>

        public let isPureClassOrID:
            Bool

        init(
            classes:
                Set<AnyHTMLClass>,
            ids:
                Set<AnyHTMLID>,
            isPureClassOrID:
                Bool
        ) {
            self.classes =
                classes

            self.ids =
                ids

            self.isPureClassOrID =
                isPureClassOrID
        }
    }

    public let representation:
        Representation

    /// Raw compatibility / escape-hatch initializer.
    ///
    /// The source remains raw rather than pretending that parsing occurred.
    /// Use `init(parsing:)` when structural interpretation is required.
    public init(
        _ source: String
    ) {
        self.representation =
            .raw(
                source
            )
    }

    private init(
        representation:
            Representation
    ) {
        self.representation =
            representation
    }

    /// Terminal CSS serialization for this selector.
    public var serialized: String {
        switch representation {
        case .raw(
            let source
        ):
            return source

        case .structured(
            let sequences
        ):
            return sequences
                .map(
                    Self.serialize
                )
                .joined(
                    separator:
                        ", "
                )
        }
    }

    /// Compatibility view for existing callers.
    ///
    /// `serialized` is the explicit serialization boundary.
    public var raw: String {
        serialized
    }

    public var description: String {
        serialized
    }

    /// Semantic class/ID information recoverable from each selector group.
    ///
    /// Raw selectors participate when the supported parser can interpret
    /// them. Unsupported raw CSS deliberately remains semantically unknown.
    public var symbolGroups:
        [SymbolGroup]?
    {
        switch representation {
        case .raw(
            let source
        ):
            guard
                let parsed =
                    try? CSSSelector(
                        parsing:
                            source
                    )
            else {
                return nil
            }

            return parsed
                .symbolGroups

        case .structured(
            let sequences
        ):
            return sequences
                .map { sequence in
                    var classes:
                        Set<AnyHTMLClass> =
                            []

                    var ids:
                        Set<AnyHTMLID> =
                            []

                    var pure =
                        sequence
                            .combinators
                            .isEmpty

                    for compound
                        in sequence.compounds
                    {
                        for selector
                            in compound.selectors
                        {
                            switch selector {
                            case .class(
                                let value
                            ):
                                classes
                                    .insert(
                                        value
                                    )

                            case .id(
                                let value
                            ):
                                ids
                                    .insert(
                                        value
                                    )

                            case .element,
                                 .universal,
                                 .pseudoClass,
                                 .pseudoElement:
                                pure =
                                    false
                            }
                        }
                    }

                    if classes.isEmpty,
                       ids.isEmpty
                    {
                        pure =
                            false
                    }

                    return SymbolGroup(
                        classes:
                            classes,
                        ids:
                            ids,
                        isPureClassOrID:
                            pure
                    )
                }
        }
    }

    /// Semantic equality normalizes raw selectors when our parser understands
    /// them. Thus `.raw(".button")` and `.class("button")` denote the same
    /// CSS selector without requiring callers to reconstruct that identity.
    public static func == (
        lhs: CSSSelector,
        rhs: CSSSelector
    ) -> Bool {
        lhs
            .normalizedRepresentation
            ==
        rhs
            .normalizedRepresentation
    }

    public func hash(
        into hasher:
            inout Hasher
    ) {
        hasher.combine(
            normalizedRepresentation
        )
    }

    private var normalizedRepresentation:
        Representation
    {
        switch representation {
        case .structured:
            return representation

        case .raw(
            let source
        ):
            return (
                try? CSSSelector(
                    parsing:
                        source
                )
            )?
            .representation
            ?? representation
        }
    }
}

public extension CSSSelector {
    static func element(
        _ name: String
    ) -> CSSSelector {
        structured(
            .element(
                name
            )
        )
    }

    static func `class`(
        _ name: String
    ) -> CSSSelector {
        .class(
            AnyHTMLClass(
                name
            )
        )
    }

    static func `class`(
        _ value:
            AnyHTMLClass
    ) -> CSSSelector {
        structured(
            .class(
                value
            )
        )
    }

    static func id(
        _ name: String
    ) -> CSSSelector {
        id(
            AnyHTMLID(
                name
            )
        )
    }

    static func id(
        _ value:
            AnyHTMLID
    ) -> CSSSelector {
        structured(
            .id(
                value
            )
        )
    }

    static func raw(
        _ value: String
    ) -> CSSSelector {
        CSSSelector(
            representation:
                .raw(
                    value
                )
        )
    }

    func pseudoClass(
        _ name: String
    ) -> CSSSelector {
        appending(
            .pseudoClass(
                name
            )
        )
    }

    func pseudoElement(
        _ name: String
    ) -> CSSSelector {
        appending(
            .pseudoElement(
                name
            )
        )
    }

    func descendant(
        _ other:
            CSSSelector
    ) -> CSSSelector {
        combining(
            other,
            with:
                .descendant
        )
    }

    func child(
        _ other:
            CSSSelector
    ) -> CSSSelector {
        combining(
            other,
            with:
                .child
        )
    }

    func sibling(
        _ sibling:
            Combinator.Sibling,
        _ other:
            CSSSelector
    ) -> CSSSelector {
        combining(
            other,
            with:
                .sibling(
                    sibling
                )
        )
    }

    func compound(
        _ other:
            CSSSelector
    ) -> CSSSelector {
        guard
            case .structured(
                let leftGroups
            ) =
                representation,
            leftGroups.count == 1,
            case .structured(
                let rightGroups
            ) =
                other.representation,
            rightGroups.count == 1,
            rightGroups[
                0
            ]
            .compounds
            .count == 1,
            rightGroups[
                0
            ]
            .combinators
            .isEmpty,
            var last =
                leftGroups[
                    0
                ]
                .compounds
                .last
        else {
            return .raw(
                serialized
                + other.serialized
            )
        }

        last =
            Compound(
                selectors:
                    last.selectors
                    + rightGroups[
                        0
                    ]
                    .compounds[
                        0
                    ]
                    .selectors
            )

        var compounds =
            leftGroups[
                0
            ]
            .compounds

        compounds[
            compounds.count - 1
        ] =
            last

        return CSSSelector(
            representation:
                .structured(
                    [
                        Sequence(
                            compounds:
                                compounds,
                            combinators:
                                leftGroups[
                                    0
                                ]
                                .combinators
                        ),
                    ]
                )
        )
    }

    static func group(
        _ selectors:
            [CSSSelector]
    ) -> CSSSelector {
        var groups:
            [Sequence] =
                []

        for selector
            in selectors
        {
            guard
                case .structured(
                    let sequences
                ) =
                    selector
                        .representation
            else {
                return .raw(
                    selectors
                        .map(
                            \.serialized
                        )
                        .joined(
                            separator:
                                ", "
                        )
                )
            }

            groups.append(
                contentsOf:
                    sequences
            )
        }

        guard
            !groups.isEmpty
        else {
            return .raw(
                ""
            )
        }

        return CSSSelector(
            representation:
                .structured(
                    groups
                )
        )
    }
}

private extension CSSSelector {
    static func structured(
        _ selector: Simple
    ) -> CSSSelector {
        CSSSelector(
            representation:
                .structured(
                    [
                        Sequence(
                            compounds: [
                                Compound(
                                    selectors: [
                                        selector,
                                    ]
                                ),
                            ],
                            combinators:
                                []
                        ),
                    ]
                )
        )
    }

    func appending(
        _ selector: Simple
    ) -> CSSSelector {
        guard
            case .structured(
                let groups
            ) =
                representation,
            groups.count == 1,
            var last =
                groups[
                    0
                ]
                .compounds
                .last
        else {
            return .raw(
                serialized
                + Self.serialize(
                    selector
                )
            )
        }

        last =
            Compound(
                selectors:
                    last.selectors
                    + [
                        selector,
                    ]
            )

        var compounds =
            groups[
                0
            ]
            .compounds

        compounds[
            compounds.count - 1
        ] =
            last

        return CSSSelector(
            representation:
                .structured(
                    [
                        Sequence(
                            compounds:
                                compounds,
                            combinators:
                                groups[
                                    0
                                ]
                                .combinators
                        ),
                    ]
                )
        )
    }

    func combining(
        _ other:
            CSSSelector,
        with combinator:
            Combinator
    ) -> CSSSelector {
        guard
            case .structured(
                let leftGroups
            ) =
                representation,
            leftGroups.count == 1,
            case .structured(
                let rightGroups
            ) =
                other.representation,
            rightGroups.count == 1
        else {
            return .raw(
                serialized
                + Self.serialize(
                    combinator
                )
                + other.serialized
            )
        }

        let left =
            leftGroups[
                0
            ]

        let right =
            rightGroups[
                0
            ]

        return CSSSelector(
            representation:
                .structured(
                    [
                        Sequence(
                            compounds:
                                left.compounds
                                + right.compounds,
                            combinators:
                                left.combinators
                                + [
                                    combinator,
                                ]
                                + right.combinators
                        ),
                    ]
                )
        )
    }

    static func serialize(
        _ sequence:
            Sequence
    ) -> String {
        guard
            let first =
                sequence
                    .compounds
                    .first
        else {
            return ""
        }

        var output =
            serialize(
                first
            )

        for index
            in sequence
                .combinators
                .indices
        {
            output +=
                serialize(
                    sequence
                        .combinators[
                            index
                        ]
                )

            output +=
                serialize(
                    sequence
                        .compounds[
                            index + 1
                        ]
                )
        }

        return output
    }

    static func serialize(
        _ compound:
            Compound
    ) -> String {
        compound
            .selectors
            .map(
                serialize
            )
            .joined()
    }

    static func serialize(
        _ selector:
            Simple
    ) -> String {
        switch selector {
        case .element(
            let name
        ):
            return name

        case .universal:
            return "*"

        case .class(
            let value
        ):
            return
                ".\(value.rawValue)"

        case .id(
            let value
        ):
            return
                "#\(value.rawValue)"

        case .pseudoClass(
            let name
        ):
            return
                ":\(name)"

        case .pseudoElement(
            let name
        ):
            return
                "::\(name)"
        }
    }

    static func serialize(
        _ combinator:
            Combinator
    ) -> String {
        switch combinator {
        case .descendant:
            return " "

        case .child:
            return " > "

        case .sibling(
            .adjacent
        ):
            return " + "

        case .sibling(
            .general
        ):
            return " ~ "
        }
    }
}
