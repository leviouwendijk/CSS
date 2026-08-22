import DSL
import Foundation

public enum CSSSelectorParseError:
    Error,
    Sendable,
    Equatable
{
    case unsupported(
        String
    )
}

public extension CSSSelector {
    init(
        parsing source:
            String
    ) throws {
        var parser =
            CSSSelectorParser(
                source
            )

        guard
            let sequences =
                parser.parse()
        else {
            throw
                CSSSelectorParseError
                    .unsupported(
                        source
                    )
        }

        self.representation =
            .structured(
                sequences
            )
    }
}

/// Parser for the structural selector subset represented by `CSSSelector`.
///
/// Unsupported CSS remains available through `CSSSelector.raw(...)`; parsing
/// does not pretend to understand syntax for which we have no structural model.
private struct CSSSelectorParser {
    private let characters:
        [Character]

    private var index:
        Int =
            0

    init(
        _ source: String
    ) {
        self.characters =
            Array(
                source
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
            )
    }

    mutating func parse()
        -> [CSSSelector.Sequence]?
    {
        guard
            !characters.isEmpty
        else {
            return nil
        }

        var groups:
            [CSSSelector.Sequence] =
                []

        while
            index
                < characters.count
        {
            guard
                let sequence =
                    parseSequence()
            else {
                return nil
            }

            groups.append(
                sequence
            )

            consumeWhitespace()

            guard
                index
                    < characters.count
            else {
                break
            }

            guard
                characters[
                    index
                ]
                    == ","
            else {
                return nil
            }

            index += 1

            consumeWhitespace()

            guard
                index
                    < characters.count
            else {
                return nil
            }
        }

        return groups
    }

    private mutating func parseSequence()
        -> CSSSelector.Sequence?
    {
        guard
            let first =
                parseCompound()
        else {
            return nil
        }

        var compounds =
            [
                first,
            ]

        var combinators:
            [CSSSelector.Combinator] =
                []

        while
            index
                < characters.count,
            characters[
                index
            ]
                != ","
        {
            let hadWhitespace =
                consumeWhitespace()

            guard
                index
                    < characters.count,
                characters[
                    index
                ]
                    != ","
            else {
                break
            }

            let combinator:
                CSSSelector.Combinator

            switch
                characters[
                    index
                ]
            {
            case ">":
                combinator =
                    .child

                index += 1
                consumeWhitespace()

            case "+":
                combinator =
                    .sibling(
                        .adjacent
                    )

                index += 1
                consumeWhitespace()

            case "~":
                combinator =
                    .sibling(
                        .general
                    )

                index += 1
                consumeWhitespace()

            default:
                guard
                    hadWhitespace
                else {
                    return nil
                }

                combinator =
                    .descendant
            }

            guard
                let compound =
                    parseCompound()
            else {
                return nil
            }

            combinators.append(
                combinator
            )

            compounds.append(
                compound
            )
        }

        return CSSSelector.Sequence(
            compounds:
                compounds,
            combinators:
                combinators
        )
    }

    private mutating func parseCompound()
        -> CSSSelector.Compound?
    {
        var selectors:
            [CSSSelector.Simple] =
                []

        while
            index
                < characters.count
        {
            let character =
                characters[
                    index
                ]

            if
                character.isWhitespace
                || character == ","
                || character == ">"
                || character == "+"
                || character == "~"
            {
                break
            }

            switch character {
            case ".":
                index += 1

                guard
                    let name =
                        parseName()
                else {
                    return nil
                }

                selectors.append(
                    .class(
                        AnyHTMLClass(
                            name
                        )
                    )
                )

            case "#":
                index += 1

                guard
                    let name =
                        parseName()
                else {
                    return nil
                }

                selectors.append(
                    .id(
                        AnyHTMLID(
                            name
                        )
                    )
                )

            case ":":
                guard
                    let pseudo =
                        parsePseudo()
                else {
                    return nil
                }

                selectors.append(
                    pseudo
                )

            case "*":
                index += 1

                selectors.append(
                    .universal
                )

            default:
                guard
                    selectors.isEmpty,
                    let name =
                        parseName()
                else {
                    return nil
                }

                selectors.append(
                    .element(
                        name
                    )
                )
            }
        }

        guard
            !selectors.isEmpty
        else {
            return nil
        }

        return CSSSelector.Compound(
            selectors:
                selectors
        )
    }

    private mutating func parsePseudo()
        -> CSSSelector.Simple?
    {
        index += 1

        let isElement =
            index
                < characters.count
            && characters[
                index
            ]
                == ":"

        if isElement {
            index += 1
        }

        guard
            var name =
                parseName()
        else {
            return nil
        }

        if
            index
                < characters.count,
            characters[
                index
            ]
                == "("
        {
            let start =
                index

            var depth =
                0

            while
                index
                    < characters.count
            {
                let character =
                    characters[
                        index
                    ]

                if
                    character
                        == "("
                {
                    depth += 1
                } else if
                    character
                        == ")"
                {
                    depth -= 1
                }

                index += 1

                if depth == 0 {
                    break
                }
            }

            guard
                depth == 0
            else {
                return nil
            }

            name +=
                String(
                    characters[
                        start..<index
                    ]
                )
        }

        return isElement
            ? .pseudoElement(
                name
            )
            : .pseudoClass(
                name
            )
    }

    private mutating func parseName()
        -> String?
    {
        let start =
            index

        while
            index
                < characters.count,
            isNameCharacter(
                characters[
                    index
                ]
            )
        {
            index += 1
        }

        guard
            index > start
        else {
            return nil
        }

        return String(
            characters[
                start..<index
            ]
        )
    }

    @discardableResult
    private mutating func consumeWhitespace()
        -> Bool
    {
        let start =
            index

        while
            index
                < characters.count,
            characters[
                index
            ]
                .isWhitespace
        {
            index += 1
        }

        return
            index > start
    }

    private func isNameCharacter(
        _ character:
            Character
    ) -> Bool {
        character.isLetter
            || character.isNumber
            || character == "-"
            || character == "_"
    }
}
