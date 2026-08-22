import DSL

/// Semantic view of a CSS custom-property declaration pulled from a stylesheet.
public struct CSSCustomProperty:
    Sendable,
    Equatable
{
    /// Selector this declaration belongs to.
    public let selector:
        CSSSelector

    /// Custom-property identity, e.g. `--bg`.
    public let name:
        AnyCSSVariable

    /// Structured CSS value.
    public let value:
        CSSValue

    public init(
        selector:
            CSSSelector,
        name:
            AnyCSSVariable,
        value:
            CSSValue
    ) {
        self.selector =
            selector

        self.name =
            name

        self.value =
            value
    }
}

@inline(__always)
public func _extractCustomCSSProperties(
    from rules:
        [CSSRule],
    selector:
        String,
    filter:
        (
            (
                CSSCustomProperty
            ) -> Bool
        )?
) -> [CSSCustomProperty] {
    let target =
        CSSSelector(
            selector
        )

    let rulesToScan =
        rules.filter {
            $0.selector
                == target
        }

    var output:
        [CSSCustomProperty] =
            []

    output.reserveCapacity(
        rulesToScan.reduce(
            0
        ) {
            $0
                + $1.declarations.count
        }
    )

    for rule
        in rulesToScan
    {
        for declaration
            in rule.declarations
        {
            guard
                case .custom(
                    let name
                ) =
                    declaration.property
            else {
                continue
            }

            let property =
                CSSCustomProperty(
                    selector:
                        rule.selector,
                    name:
                        name,
                    value:
                        declaration.value
                )

            if
                let filter,
                !filter(
                    property
                )
            {
                continue
            }

            output.append(
                property
            )
        }
    }

    return output
}
