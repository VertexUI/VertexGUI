import Foundation

public struct StyleSelector: Hashable, ExpressibleByStringLiteral {
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

    public func selects<W: Widget>(_ widget: W) -> Bool {
        if widget.classes.count < classes.count {
            return false
        }

        let selectorClasses = classes.sorted()
        let widgetClasses = widget.classes.sorted()
        return selectorClasses.allSatisfy(widgetClasses.contains)
    }
}

extension StyleSelector {
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

        private var result = StyleSelector()
        private var nextResultType: ParsingBufferResultType? = nil
        private var nextResultBuffer: String = "" 

        public init(_ string: String) {
            self.string = string
        }

        mutating public func parse() throws -> StyleSelector {
            for (index, character) in string.enumerated() {
                if index == 0 && character == StyleSelector.parentExtensionSymbol {
                    result.extendsParent = true
                } else if character == StyleSelector.classSymbol {
                    flushCurrentBuffer()
                    nextResultType = .class
                } else if character == StyleSelector.pseudoClassSymbol {
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