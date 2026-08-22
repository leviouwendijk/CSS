import Foundation

/// High-level representation of a palette / set of CSS tokens you want to inspect visually.
public struct RenderedStyleProfile: Sendable, Equatable {
    public struct Swatch: Sendable, Equatable {
        /// CSS custom property name, e.g. `"--bg"`.
        public var name: String
        /// Human / raw label for the value, e.g. `"#ffffff"` or `"var(--gray-500)"`.
        public var value: String

        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }
    }

    public struct Group: Sendable, Equatable {
        public var title: String
        public var swatches: [Swatch]

        public init(
            title: String,
            swatches: [Swatch]
        ) {
            self.title = title
            self.swatches = swatches
        }
    }

    public var title: String
    public var subtitle: String?
    public var groups: [Group]

    public init(
        title: String,
        subtitle: String? = nil,
        groups: [Group]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.groups = groups
    }
}

public extension RenderedStyleProfile {
    /// Build a swatch profile from a stylesheet.
    ///
    /// If the stylesheet was created from meta sections, those drive the grouping.
    /// Otherwise, all tokens end up in a single group.
    static func fromStyleSheet(
        _ sheet: CSSStyleSheet,
        title: String,
        subtitle: String? = nil,
        selector: String = ":root",
        includeUngroupedGroup: Bool = true,
        ungroupedTitle: String = "Other tokens"
    ) -> RenderedStyleProfile {
        if let sections = sheet.rules_metasection {
            return fromRuleMetaSections(
                sheet,
                ruleSections: sections,
                title: title,
                subtitle: subtitle,
                selector: selector,
                includeUngroupedGroup: includeUngroupedGroup,
                ungroupedTitle: ungroupedTitle
            )
        } else {
            // No meta info – just dump everything into one group.
            let tokens = sheet.customProperties(selector: selector)

            let group = Group(
                title: "All tokens",
                swatches: tokens
                    .sorted { $0.name.rawValue < $1.name.rawValue }
                    .map { Swatch(name: $0.name.rawValue, value: $0.value.serialized) }
            )

            return RenderedStyleProfile(
                title: title,
                subtitle: subtitle,
                groups: [group]
            )
        }
    }

    /// Internal helper: meta-section driven grouping with optional leftovers.
    private static func fromRuleMetaSections(
        _ sheet: CSSStyleSheet,
        ruleSections: [CSSRuleMetaSection],
        title: String,
        subtitle: String?,
        selector: String,
        includeUngroupedGroup: Bool,
        ungroupedTitle: String
    ) -> RenderedStyleProfile {
        var groups: [Group] = []
        var usedNames = Set<String>()

        for section in ruleSections {
            let tokens = section.customProperties(selector: selector)
            guard !tokens.isEmpty else { continue }

            let swatches = tokens
                .sorted { $0.name.rawValue < $1.name.rawValue }
                .map {
                    usedNames.insert($0.name.rawValue)
                    return Swatch(name: $0.name.rawValue, value: $0.value.serialized)
                }

            groups.append(
                Group(
                    title: section.title,
                    swatches: swatches
                )
            )
        }

        if includeUngroupedGroup {
            let allTokens = sheet.customProperties(selector: selector)
            let leftovers = allTokens
                .filter { !usedNames.contains($0.name.rawValue) }
                .sorted { $0.name.rawValue < $1.name.rawValue }
                .map { Swatch(name: $0.name.rawValue, value: $0.value.serialized) }

            if !leftovers.isEmpty {
                groups.append(
                    Group(
                        title: ungroupedTitle,
                        swatches: leftovers
                    )
                )
            }
        }

        return RenderedStyleProfile(
            title: title,
            subtitle: subtitle,
            groups: groups
        )
    }
}
