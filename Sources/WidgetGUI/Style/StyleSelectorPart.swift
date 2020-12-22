import Foundation

public struct StyleSelectorPart: Equatable, Hashable, ExpressibleByStringLiteral {
    public var extendsParent: Bool
    public var classes: [String]
    public var pseudoClasses: [String]

    public init(extendsParent: Bool = false, classes: [String] = [], pseudoClasses: [String] = []) {
        self.extendsParent = extendsParent
        self.classes = classes
        self.pseudoClasses = pseudoClasses
    }

    public init(parse stringLiteral: String) throws {
        var parser = SelectorStringParser(stringLiteral)
        self = try parser.parse()
    }

    public init(stringLiteral: String) {
        try! self.init(parse: stringLiteral)
    }

    /**
    - Returns: `true` if classes, pseudoClasses fully or partially match the given widget. Whereby the Widget can contain elements that are not in the selector, but the selector cannot contain elements that are not in the Widget.
    An empty part always selects any widget (returns `true`).
    Otherwise returns `false`.
    */
    public func selects(_ widget: Widget) -> Bool {
        if widget.classes.count < classes.count {
            return false
        }

        let selectorClasses = classes.sorted()
        let widgetClasses = widget.classes.sorted()
        return selectorClasses.allSatisfy(widgetClasses.contains)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.extendsParent == rhs.extendsParent && 
        lhs.classes.count == rhs.classes.count &&
        lhs.pseudoClasses.count == rhs.pseudoClasses.count && 
        lhs.classes.sorted() == rhs.classes.sorted() && 
        lhs.pseudoClasses.sorted() == rhs.pseudoClasses.sorted()
    }
}

extension StyleSelectorPart {
    private static let parentExtensionSymbol = Character("&")
    private static let classSymbol = Character(".")
    private static let pseudoClassSymbol = Character(":")
    private static let allowedIdentifierCharacters = CharacterSet.letters
        .union(CharacterSet.decimalDigits)
        .union(CharacterSet(["-", "_"]))

    private enum ParsingBufferResultType {
        case `class`, pseudoClass
    }

    public struct LiteralSyntaxEerror: LocalizedError {
        public let string: String

        public var errorDescription: String? {
            "unexpected string \"\(string)\""
        }
    }

    public struct SelectorStringParser {
        private let string: String

        private var result = StyleSelectorPart()
        private var nextResultType: ParsingBufferResultType? = nil
        private var nextResultBuffer: String = "" 

        public init(_ string: String) {
            self.string = string
        }

        mutating public func parse() throws -> StyleSelectorPart {
            for (index, character) in string.enumerated() {
                if index == 0 && character == StyleSelectorPart.parentExtensionSymbol {
                    result.extendsParent = true
                } else if character == StyleSelectorPart.classSymbol {
                    flushCurrentBuffer()
                    nextResultType = .class
                } else if character == StyleSelectorPart.pseudoClassSymbol {
                    flushCurrentBuffer()
                    nextResultType = .pseudoClass
                } else if character.unicodeScalars.allSatisfy(allowedIdentifierCharacters.contains) {
                    nextResultBuffer.append(character)
                } else {
                    throw LiteralSyntaxEerror(string: String(character))
                }
            }
            flushCurrentBuffer()
            return result
        }

        mutating private func flushCurrentBuffer() {
            if let nextResultType = nextResultType {
                switch nextResultType {
                case .class:
                    result.classes.append(nextResultBuffer)
                case .pseudoClass:
                    result.pseudoClasses.append(nextResultBuffer)
                }
            }
            nextResultType = nil
            nextResultBuffer = ""
        }
    }
}