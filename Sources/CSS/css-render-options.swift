import Foundation

public enum CSSUnreferenced: Sendable {
    /// Leave all rules unchanged, no pruning.
    case keep
    /// Drop rules that are *provably* unused.
    case drop
    /// Keep unused rules, but wrap them in a comment block so they are still visible.
    case commented
}

public struct CSSRenderOptions: Sendable {
    public var indentStep: Int
    public var ensureTrailingNewline: Bool

    /// Classes seen in the HTML.
    public var usedClassNames: Set<String>?

    /// IDs seen in the HTML.
    public var usedIDs: Set<String>?

    public var unreferenced: CSSUnreferenced

    public var mergeDuplicateSelectors: Bool

    public init(
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = false,
        usedClassNames: Set<String>? = nil,
        usedIDs: Set<String>? = nil,
        unreferenced: CSSUnreferenced = .keep,
        mergeDuplicateSelectors: Bool = true
    ) {
        self.indentStep = indentStep
        self.ensureTrailingNewline = ensureTrailingNewline
        self.usedClassNames = usedClassNames
        self.usedIDs = usedIDs
        self.unreferenced = unreferenced
        self.mergeDuplicateSelectors = mergeDuplicateSelectors
    }
}
