import CSS
import DSL
import TestFlows

@main
enum CSSTestFlowMain {
    static func main() async {
        await TestFlowCLI.run(
            suite:
                CSSFlowSuite.self
        )
    }
}

enum CSSFlowSuite:
    TestFlowRegistry
{
    static let title =
        "CSS semantic flows"

    static let flows:
        [TestFlow] =
    [
        selectorRoundTrip,
        siblingRoundTrip,
        selectorCanonicalization,
        rawSelectorBoundary,
        ruleRetention,
        declarationRoundTrip,
        compoundValueRetention,
        customPropertyRetention,
        animationIdentityRetention,
        contributionResolution,
    ]

    static let selectorRoundTrip =
        TestFlow(
            "selector-round-trip",
            title:
                "Typed selector identity survives serialization and parsing",
            tags: [
                "css",
                "selector",
                "semantic",
                "round-trip",
            ]
        ) {
            Step(
                "compose typed class and id selector"
            ) {
                let navigation =
                    HTMLClass<
                        SelectorNamespace
                    >(
                        "navigation"
                    )

                let active =
                    HTMLClass<
                        SelectorNamespace
                    >(
                        "active"
                    )

                let cta =
                    HTMLID<
                        SelectorNamespace
                    >(
                        "cta"
                    )

                let selector =
                    CSSSelector
                        .class(
                            navigation
                        )
                        .compound(
                            CSSSelector
                                .class(
                                    active
                                )
                        )
                        .pseudoClass(
                            "hover"
                        )
                        .child(
                            CSSSelector
                                .id(
                                    cta
                                )
                        )

                try Expect.equal(
                    selector.serialized,
                    ".navigation.active:hover > #cta",
                    "selector.serialized"
                )

                let parsed =
                    try CSSSelector(
                        parsing:
                            selector.serialized
                    )

                try Expect.equal(
                    parsed,
                    selector,
                    "selector.round-trip"
                )
            }

            Step(
                "retain recoverable CSS class and id identity"
            ) {
                let navigation =
                    HTMLClass<
                        SelectorNamespace
                    >(
                        "navigation"
                    )

                let cta =
                    HTMLID<
                        SelectorNamespace
                    >(
                        "cta"
                    )

                let selector =
                    CSSSelector
                        .class(
                            navigation
                        )
                        .child(
                            CSSSelector
                                .id(
                                    cta
                                )
                        )

                let groups =
                    selector
                        .symbolGroups
                    ?? []

                try Expect.equal(
                    groups.count,
                    1,
                    "selector.symbol-group-count"
                )

                guard
                    let group =
                        groups.first
                else {
                    throw
                        CSSFlowFailure
                            .missingSymbolGroup
                }

                try Expect.equal(
                    group
                        .classes
                        .contains(
                            navigation.erased
                        ),
                    true,
                    "selector.navigation-class"
                )

                try Expect.equal(
                    group
                        .ids
                        .contains(
                            cta.erased
                        ),
                    true,
                    "selector.cta-id"
                )

                try Expect.equal(
                    group.isPureClassOrID,
                    false,
                    "selector.combinator-is-not-simple-prune-target"
                )
            }
        }

    static let siblingRoundTrip =
        TestFlow(
            "selector-sibling-round-trip",
            title:
                "Adjacent and general sibling relations remain nested semantic combinators",
            tags: [
                "css",
                "selector",
                "sibling",
                "round-trip",
            ]
        ) {
            Step(
                "adjacent sibling"
            ) {
                let selector =
                    CSSSelector
                        .class(
                            "item"
                        )
                        .sibling(
                            .adjacent,
                            CSSSelector
                                .class(
                                    "label"
                                )
                        )

                try Expect.equal(
                    selector.serialized,
                    ".item + .label",
                    "selector.sibling.adjacent.serialized"
                )

                let parsed =
                    try CSSSelector(
                        parsing:
                            selector.serialized
                    )

                try Expect.equal(
                    parsed,
                    selector,
                    "selector.sibling.adjacent.round-trip"
                )
            }

            Step(
                "general sibling"
            ) {
                let selector =
                    CSSSelector
                        .class(
                            "item"
                        )
                        .sibling(
                            .general,
                            CSSSelector
                                .class(
                                    "label"
                                )
                        )

                try Expect.equal(
                    selector.serialized,
                    ".item ~ .label",
                    "selector.sibling.general.serialized"
                )

                let parsed =
                    try CSSSelector(
                        parsing:
                            selector.serialized
                    )

                try Expect.equal(
                    parsed,
                    selector,
                    "selector.sibling.general.round-trip"
                )
            }
        }

    static let selectorCanonicalization =
        TestFlow(
            "selector-canonicalization",
            title:
                "Parsed selector syntax stabilizes through canonical serialization",
            tags: [
                "css",
                "selector",
                "parser",
                "canonicalization",
            ]
        ) {
            Step(
                "canonicalize spacing and selector groups"
            ) {
                let first =
                    try CSSSelector(
                        parsing:
                            "  .one,#two > .three  "
                    )

                try Expect.equal(
                    first.serialized,
                    ".one, #two > .three",
                    "selector.canonical-text"
                )

                let second =
                    try CSSSelector(
                        parsing:
                            first.serialized
                    )

                try Expect.equal(
                    second,
                    first,
                    "selector.canonical-round-trip"
                )
            }
        }

    static let rawSelectorBoundary =
        TestFlow(
            "selector-raw-boundary",
            title:
                "Unsupported selector syntax remains an explicit raw escape hatch",
            tags: [
                "css",
                "selector",
                "raw",
                "serialization-frontier",
            ]
        ) {
            Step(
                "unsupported syntax stays raw"
            ) {
                let selector =
                    CSSSelector.raw(
                        "[data-state='open']"
                    )

                try Expect.equal(
                    selector.serialized,
                    "[data-state='open']",
                    "selector.raw.serialized"
                )

                let parsed =
                    try? CSSSelector(
                        parsing:
                            selector.serialized
                    )

                try Expect.equal(
                    parsed == nil,
                    true,
                    "selector.raw.unsupported-parser"
                )
            }

            Step(
                "parseable raw syntax normalizes semantically"
            ) {
                let raw =
                    CSSSelector.raw(
                        ".button"
                    )

                let structured =
                    CSSSelector.class(
                        "button"
                    )

                try Expect.equal(
                    raw,
                    structured,
                    "selector.raw.structured-equivalence"
                )
            }
        }

    static let ruleRetention =
        TestFlow(
            "selector-rule-retention",
            title:
                "Rules and stylesheet operations consume retained selector semantics",
            tags: [
                "css",
                "selector",
                "rule",
                "pruning",
                "merge",
            ]
        ) {
            Step(
                "typed DSL selector survives into CSSRule"
            ) {
                let used =
                    HTMLClass<
                        SelectorNamespace
                    >(
                        "used"
                    )

                let rule =
                    CSS.rule(
                        used,
                        CSS.decl(
                            "color",
                            "green"
                        )
                    )

                try Expect.equal(
                    rule.selector,
                    CSSSelector.class(
                        used
                    ),
                    "rule.selector"
                )
            }

            Step(
                "pruning consumes selector semantics"
            ) {
                let sheet =
                    CSSStyleSheet(
                        rules: [
                            CSS.rule(
                                CSSSelector.class(
                                    "used"
                                ),
                                CSS.decl(
                                    "color",
                                    "green"
                                )
                            ),

                            CSS.rule(
                                CSSSelector.class(
                                    "unused"
                                ),
                                CSS.decl(
                                    "color",
                                    "red"
                                )
                            ),

                            CSS.rule(
                                CSSSelector
                                    .class(
                                        "unused"
                                    )
                                    .pseudoClass(
                                        "hover"
                                    ),
                                CSS.decl(
                                    "color",
                                    "blue"
                                )
                            ),

                            CSS.rule(
                                ".raw-unused",
                                CSS.decl(
                                    "display",
                                    "none"
                                )
                            ),
                        ]
                    )

                let rendered =
                    sheet.render(
                        options:
                            CSSRenderOptions(
                                usedClassNames: [
                                    "used",
                                ],
                                unreferenced:
                                    .drop,
                                mergeDuplicateSelectors:
                                    false
                            )
                    )

                try Expect.equal(
                    rendered.contains(
                        ".used {"
                    ),
                    true,
                    "render.used-selector"
                )

                try Expect.equal(
                    rendered.contains(
                        ".unused {"
                    ),
                    false,
                    "render.unused-selector"
                )

                try Expect.equal(
                    rendered.contains(
                        ".unused:hover {"
                    ),
                    true,
                    "render.complex-selector-conservative"
                )

                try Expect.equal(
                    rendered.contains(
                        ".raw-unused {"
                    ),
                    false,
                    "render.parseable-raw-selector"
                )
            }

            Step(
                "duplicate merging uses semantic selector equality"
            ) {
                let sheet =
                    CSSStyleSheet(
                        rules: [
                            CSS.rule(
                                ".same",
                                CSS.decl(
                                    "color",
                                    "red"
                                )
                            ),

                            CSS.rule(
                                CSSSelector.class(
                                    "same"
                                ),
                                CSS.decl(
                                    "display",
                                    "block"
                                )
                            ),
                        ]
                    )
                    .mergingDuplicateSelectors()

                try Expect.equal(
                    sheet.rules.count,
                    1,
                    "merge.selector-count"
                )

                try Expect.equal(
                    sheet
                        .rules[
                            0
                        ]
                        .declarations
                        .count,
                    2,
                    "merge.declaration-count"
                )
            }
        }

    static let declarationRoundTrip =
        TestFlow(
            "declaration-round-trip",
            title:
                "CSS declarations retain custom-property and variable-reference semantics",
            tags: [
                "css",
                "declaration",
                "variable",
                "round-trip",
            ]
        ) {
            Step(
                "retain typed custom-property identity"
            ) {
                let surface =
                    CSSVariable<
                        SelectorNamespace
                    >(
                        "surface"
                    )

                let base =
                    CSSVariable<
                        SelectorNamespace
                    >(
                        "base"
                    )

                let fallback =
                    CSSVariable<
                        SelectorNamespace
                    >(
                        "fallback"
                    )

                let declaration =
                    CSS.decl(
                        surface,
                        CSS.variable(
                            base,
                            fallback:
                                CSS.variable(
                                    fallback,
                                    fallback:
                                        "#ffffff"
                                )
                        )
                    )

                try Expect.equal(
                    declaration.property,
                    CSSProperty.custom(
                        surface.erased
                    ),
                    "declaration.custom-property"
                )

                try Expect.equal(
                    declaration
                        .value
                        .variableReferences
                        .map(
                            \.rawValue
                        ),
                    [
                        "--base",
                        "--fallback",
                    ],
                    "declaration.variable-references"
                )

                try Expect.equal(
                    declaration.serialized,
                    "--surface: var(--base, var(--fallback, #ffffff));",
                    "declaration.serialized"
                )
            }

            Step(
                "serialize and parse back into the same declaration"
            ) {
                let original =
                    try CSSDeclaration(
                        parsing:
                            "--surface: var(--base, var(--fallback, #ffffff));"
                    )

                let reparsed =
                    try CSSDeclaration(
                        parsing:
                            original.serialized
                    )

                try Expect.equal(
                    reparsed,
                    original,
                    "declaration.round-trip"
                )
            }

            Step(
                "ordinary properties remain ordinary CSS syntax"
            ) {
                let declaration =
                    try CSSDeclaration(
                        parsing:
                            "display: grid;"
                    )

                try Expect.equal(
                    declaration.property,
                    CSSProperty.raw(
                        "display"
                    ),
                    "declaration.raw-property"
                )

                try Expect.equal(
                    declaration
                        .value
                        .variableReferences
                        .isEmpty,
                    true,
                    "declaration.raw-value-has-no-variable-reference"
                )
            }
        }

    static let compoundValueRetention =
        TestFlow(
            "compound-value-retention",
            title:
                "CSS variable identity survives inside larger interpolated values",
            tags: [
                "css",
                "value",
                "variable",
                "interpolation",
            ]
        ) {
            Step(
                "retain variable reference inside border syntax"
            ) {
                let border =
                    CSSVariable<
                        SelectorNamespace
                    >(
                        "border"
                    )

                let declaration =
                    CSS.decl(
                        "border",
                        "1px solid \(cssvar(border, fallback: "rgba(15, 23, 42, 0.10)"))"
                    )

                try Expect.equal(
                    declaration.serialized,
                    "border: 1px solid var(--border, rgba(15, 23, 42, 0.10));",
                    "compound-value.serialized"
                )

                try Expect.equal(
                    declaration
                        .value
                        .variableReferences,
                    [
                        border.erased,
                    ],
                    "compound-value.variable-reference"
                )
            }

            Step(
                "parse embedded variable syntax from raw CSS"
            ) {
                let value =
                    try CSSValue(
                        parsing:
                            "calc(100% - var(--space, 16px))"
                    )

                try Expect.equal(
                    value.serialized,
                    "calc(100% - var(--space, 16px))",
                    "compound-value.parsed-serialization"
                )

                try Expect.equal(
                    value
                        .variableReferences
                        .map(
                            \.rawValue
                        ),
                    [
                        "--space",
                    ],
                    "compound-value.parsed-reference"
                )
            }

            Step(
                "quoted var syntax remains literal text"
            ) {
                let value =
                    try CSSValue(
                        parsing:
                            #"url("var(--not-a-reference)")"#
                    )

                try Expect.equal(
                    value
                        .variableReferences
                        .isEmpty,
                    true,
                    "compound-value.quoted-reference"
                )
            }
        }

    static let customPropertyRetention =
        TestFlow(
            "custom-property-retention",
            title:
                "Stylesheet profiling reads retained custom-property semantics without reparsing property names",
            tags: [
                "css",
                "custom-property",
                "stylesheet",
                "semantic",
            ]
        ) {
            Step(
                "extract semantic custom property"
            ) {
                let surface =
                    CSSVariable<
                        SelectorNamespace
                    >(
                        "surface"
                    )

                let base =
                    CSSVariable<
                        SelectorNamespace
                    >(
                        "base"
                    )

                let sheet =
                    CSSStyleSheet(
                        rules: [
                            CSS.rule(
                                CSSSelector.raw(
                                    ":root"
                                ),
                                CSS.decl(
                                    surface,
                                    CSS.variable(
                                        base,
                                        fallback:
                                            "#ffffff"
                                    )
                                ),
                                CSS.decl(
                                    "color",
                                    "red"
                                )
                            ),
                        ]
                    )

                let properties =
                    sheet.customProperties()

                try Expect.equal(
                    properties.count,
                    1,
                    "custom-property.count"
                )

                guard
                    let property =
                        properties.first
                else {
                    throw
                        CSSFlowFailure
                            .missingCustomProperty
                }

                try Expect.equal(
                    property.name,
                    surface.erased,
                    "custom-property.name"
                )

                try Expect.equal(
                    property.value,
                    CSS.variable(
                        base,
                        fallback:
                            "#ffffff"
                    ),
                    "custom-property.value"
                )

                try Expect.equal(
                    property.selector,
                    CSSSelector.raw(
                        ":root"
                    ),
                    "custom-property.selector"
                )
            }
        }


    static let animationIdentityRetention =
        TestFlow(
            "animation-identity-retention",
            title:
                "Animation names and keyframe selectors remain semantic until serialization",
            tags: [
                "css",
                "animation",
                "keyframes",
                "semantic",
            ]
        ) {
            Step(
                "retain keyframe animation identity"
            ) {
                let fade:
                    CSSAnimationName =
                        "fade-in"

                let keyframes =
                    CSS.keyframes(
                        fade
                    ) {
                        CSS.from {
                            CSS.decl(
                                "opacity",
                                "0"
                            )
                        }

                        CSS.pct(
                            50
                        ) {
                            CSS.decl(
                                "opacity",
                                "0.5"
                            )
                        }

                        CSS.to {
                            CSS.decl(
                                "opacity",
                                "1"
                            )
                        }
                    }

                try Expect.equal(
                    keyframes.name,
                    fade,
                    "keyframes.name"
                )

                try Expect.equal(
                    keyframes
                        .steps
                        .map(
                            \.selector
                        ),
                    [
                        .from,
                        .percentage(
                            50
                        ),
                        .to,
                    ],
                    "keyframes.selectors"
                )
            }

            Step(
                "retain animation reference inside shorthand value"
            ) {
                let fade:
                    CSSAnimationName =
                        "fade-in"

                let declaration =
                    CSS.decl(
                        "animation",
                        "\(fade) 140ms ease both"
                    )

                try Expect.equal(
                    declaration
                        .value
                        .animationReferences,
                    [
                        fade,
                    ],
                    "animation.references"
                )

                try Expect.equal(
                    declaration.serialized,
                    "animation: fade-in 140ms ease both;",
                    "animation.serialized"
                )
            }

            Step(
                "retain animation-name reference as a direct value"
            ) {
                let fade:
                    CSSAnimationName =
                        "fade-in"

                let declaration =
                    CSS.decl(
                        "animation-name",
                        CSS.animation(
                            fade
                        )
                    )

                try Expect.equal(
                    declaration
                        .value
                        .animationReferences,
                    [
                        fade,
                    ],
                    "animation-name.references"
                )

                try Expect.equal(
                    declaration.serialized,
                    "animation-name: fade-in;",
                    "animation-name.serialized"
                )
            }

            Step(
                "string keyframe conveniences still become semantic"
            ) {
                let keyframes =
                    CSS.keyframes(
                        "legacy-fade"
                    ) {
                        CSS.step(
                            "50%"
                        ) {
                            CSS.decl(
                                "opacity",
                                "0.5"
                            )
                        }
                    }

                try Expect.equal(
                    keyframes.name,
                    CSSAnimationName(
                        "legacy-fade"
                    ),
                    "keyframes.string-name"
                )

                try Expect.equal(
                    keyframes
                        .steps[
                            0
                        ]
                        .selector,
                    .percentage(
                        50
                    ),
                    "keyframes.string-selector"
                )
            }

            Step(
                "render only at the terminal CSS boundary"
            ) {
                let fade:
                    CSSAnimationName =
                        "fade-in"

                let sheet =
                    CSSStyleSheet(
                        rules: [
                            CSS.rule(
                                ".target",
                                CSS.decl(
                                    "animation",
                                    "\(fade) 140ms ease both"
                                )
                            ),
                        ],
                        keyframes: [
                            CSS.keyframes(
                                fade
                            ) {
                                CSS.from {
                                    CSS.decl(
                                        "opacity",
                                        "0"
                                    )
                                }

                                CSS.to {
                                    CSS.decl(
                                        "opacity",
                                        "1"
                                    )
                                }
                            },
                        ]
                    )

                let rendered =
                    sheet.render()

                try Expect.equal(
                    rendered.contains(
                        "@keyframes fade-in {"
                    ),
                    true,
                    "animation.rendered-keyframes"
                )

                try Expect.equal(
                    rendered.contains(
                        "animation: fade-in 140ms ease both;"
                    ),
                    true,
                    "animation.rendered-reference"
                )
            }
        }


    static let contributionResolution =
        TestFlow(
            "contribution-resolution",
            title:
                "CSS dependency identity resolves without erasing rich contribution structure",
            tags: [
                "css",
                "contribution",
                "identity",
                "resolution",
            ]
        ) {
            Step(
                "deduplicate equivalent repeated identity"
            ) {
                let navigation =
                    CSS.contribution(
                        ContributionIdentity
                            .navigation
                    ) {
                        CSS.rule(
                            ".navigation",
                            CSS.decl(
                                "display",
                                "flex"
                            )
                        )
                    }

                let unresolved =
                    CSS.contributions {
                        navigation
                        navigation

                        CSS.contribution(
                            ContributionIdentity
                                .table
                        ) {
                            CSS.rule(
                                ".table",
                                CSS.decl(
                                    "width",
                                    "100%"
                                )
                            )
                        }
                    }

                try Expect.equal(
                    unresolved
                        .contributions
                        .count,
                    3,
                    "contributions.unresolved-count"
                )

                let resolved =
                    try unresolved
                        .resolve()

                try Expect.equal(
                    resolved
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "navigation",
                        "table",
                    ],
                    "contributions.resolved-order"
                )

                try Expect.equal(
                    resolved
                        .contributions
                        .count,
                    2,
                    "contributions.resolved-count"
                )
            }

            Step(
                "reject conflicting repeated identity"
            ) {
                let first =
                    CSS.contribution(
                        ContributionIdentity
                            .navigation
                    ) {
                        CSS.rule(
                            ".navigation",
                            CSS.decl(
                                "display",
                                "flex"
                            )
                        )
                    }

                let conflicting =
                    CSS.contribution(
                        ContributionIdentity
                            .navigation
                    ) {
                        CSS.rule(
                            ".navigation",
                            CSS.decl(
                                "display",
                                "grid"
                            )
                        )
                    }

                do {
                    _ =
                        try CSSContributions(
                            [
                                first,
                                conflicting,
                            ]
                        )
                        .resolve()

                    throw
                        CSSFlowFailure
                            .expectedContributionConflict
                } catch
                    let error
                        as CSSContributionResolutionError
                {
                    try Expect.equal(
                        error,
                        .conflicting(
                            identifier:
                                ContributionIdentity
                                    .navigation
                                    .cssContributionIdentifier
                        ),
                        "contributions.conflict"
                    )
                }
            }

            Step(
                "retain rich content after resolution"
            ) {
                let contribution =
                    CSS.contribution(
                        ContributionIdentity
                            .navigation
                    ) {
                        CSS.rule(
                            CSSSelector
                                .class(
                                    "navigation"
                                )
                                .pseudoClass(
                                    "hover"
                                ),
                            CSS.decl(
                                "opacity",
                                "0.9"
                            )
                        )
                    }

                let resolved =
                    try CSSContributions(
                        [
                            contribution,
                        ]
                    )
                    .resolve()

                guard
                    let retained =
                        resolved[
                            ContributionIdentity
                                .navigation
                        ]
                else {
                    throw
                        CSSFlowFailure
                            .missingContribution
                }

                try Expect.equal(
                    retained.content,
                    contribution.content,
                    "contributions.rich-content"
                )

                try Expect.equal(
                    retained
                        .content
                        .units
                        .count,
                    1,
                    "contributions.rich-unit-count"
                )
            }

            Step(
                "scope remains selection not identity"
            ) {
                let interactive:
                    ScopeIdentifier =
                        "interactive"

                let contribution =
                    CSS.contribution(
                        ContributionIdentity
                            .navigation
                    ) {
                        CSS.rule(
                            ".navigation",
                            CSS.decl(
                                "display",
                                "flex"
                            )
                        )

                        CSS.bundle(
                            interactive
                        ) {
                            CSS.rule(
                                ".navigation-expanded",
                                CSS.decl(
                                    "display",
                                    "block"
                                )
                            )
                        }
                    }

                let resolved =
                    try CSSContributions(
                        [
                            contribution,
                        ]
                    )
                    .resolve()

                let unscoped =
                    resolved
                        .collected(
                            .unscoped
                        )
                        .render()

                let all =
                    resolved
                        .collected(
                            .all
                        )
                        .render()

                try Expect.equal(
                    unscoped.contains(
                        ".navigation {"
                    ),
                    true,
                    "contributions.scope.unscoped-base"
                )

                try Expect.equal(
                    unscoped.contains(
                        ".navigation-expanded {"
                    ),
                    false,
                    "contributions.scope.unscoped-excludes-scoped"
                )

                try Expect.equal(
                    all.contains(
                        ".navigation-expanded {"
                    ),
                    true,
                    "contributions.scope.all-includes-scoped"
                )

                try Expect.equal(
                    resolved
                        .identifiers,
                    [
                        ContributionIdentity
                            .navigation
                            .cssContributionIdentifier,
                    ],
                    "contributions.identity-independent-from-scope"
                )
            }

            Step(
                "nested unresolved collections compose before resolution"
            ) {
                let shared =
                    CSS.contributions {
                        CSS.contribution(
                            ContributionIdentity
                                .navigation
                        ) {
                            CSS.rule(
                                ".navigation",
                                CSS.decl(
                                    "display",
                                    "flex"
                                )
                            )
                        }
                    }

                let composed =
                    CSS.contributions {
                        shared
                        shared

                        CSS.contribution(
                            ContributionIdentity
                                .table
                        ) {
                            CSS.rule(
                                ".table",
                                CSS.decl(
                                    "width",
                                    "100%"
                                )
                            )
                        }
                    }

                try Expect.equal(
                    composed
                        .contributions
                        .count,
                    3,
                    "contributions.composed-unresolved-count"
                )

                let resolved =
                    try composed
                        .resolve()

                try Expect.equal(
                    resolved
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "navigation",
                        "table",
                    ],
                    "contributions.composed-resolved-order"
                )
            }
        }

}

private enum SelectorNamespace {}

private enum ContributionIdentity:
    String,
    CSSContributionIdentifying
{
    case navigation
    case table
}

private enum CSSFlowFailure:
    Error
{
    case missingSymbolGroup
    case missingCustomProperty
    case missingContribution
    case expectedContributionConflict
}
