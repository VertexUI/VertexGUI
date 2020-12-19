import Foundation

public struct StyleSelector: Hashable, ExpressibleByStringLiteral {
    // TODO: make initializable from string literal
    public let type: ObjectIdentifier?
    public let classes: [String]
    public let pseudoClasses: [String]

    public init<T: Widget>(type: T.Type, classes: [String] = [], pseudoClasses: [String] = []) {
        self.type = ObjectIdentifier(type)
        self.classes = classes
        self.pseudoClasses = pseudoClasses
    }

    public init(classes: [String] = [], pseudoClasses: [String] = []) {
        self.type = nil
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
        if let type = type, ObjectIdentifier(W.self) != type {
            return false
        }

        let selectorClasses = classes.sorted()
        let widgetClasses = widget.classes.sorted()
        return selectorClasses.allSatisfy(widgetClasses.contains)
    }
}

extension StyleSelector {
    private static let classIndicator = Character(".")
    private static let pseudoClassIndiator = Character(":")
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

        private var classes = [String]()
        private var pseudoClasses = [String]()
        private var nextResultType: ParsingBufferResultType? = nil
        private var nextResultBuffer: String = "" 

        public init(_ string: String) {
            self.string = string
        }

        mutating public func parse() throws -> StyleSelector {
            for character in string {
                if character == StyleSelector.classIndicator {
                    flushCurrentBuffer()
                    nextResultType = .class
                } else if character == StyleSelector.pseudoClassIndiator {
                    flushCurrentBuffer()
                    nextResultType = .pseudoClass
                } else if character.unicodeScalars.allSatisfy(allowedIdentifierCharacters.contains) {
                    nextResultBuffer.append(character)
                } else {
                    throw LiteralSyntaxEerror(string: String(character))
                }
            }
            flushCurrentBuffer()
            return StyleSelector(classes: classes, pseudoClasses: pseudoClasses)
        }

        mutating private func flushCurrentBuffer() {
            if let nextResultType = nextResultType {
                switch nextResultType {
                case .class:
                    classes.append(nextResultBuffer)
                case .pseudoClass:
                    pseudoClasses.append(nextResultBuffer)
                }
            }
            nextResultType = nil
            nextResultBuffer = ""
        }
    }
}