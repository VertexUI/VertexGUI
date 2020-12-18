import Foundation

public struct WidgetSelector: Hashable, ExpressibleByStringLiteral {
    // TODO: make initializable from string literal
    public let type: ObjectIdentifier?
    public let classes: [String]

    public init<T: Widget>(type: T.Type, classes: [String] = []) {
        self.type = ObjectIdentifier(type)
        self.classes = classes
    }

    public init(classes: [String]) {
        self.type = nil
        self.classes = classes
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

extension WidgetSelector {
    private static let classIndicator = Character(".")
    private static let allowedIdentifierCharacters = CharacterSet.letters.union(CharacterSet.decimalDigits)

    private enum ParsingBufferResultType {
        case `class`
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
        private var nextResultType: ParsingBufferResultType? = nil
        private var nextResultBuffer: String = "" 

        public init(_ string: String) {
            self.string = string
        }

        mutating public func parse() throws -> WidgetSelector {
            for character in string {
                if character == WidgetSelector.classIndicator {
                    flushCurrentBuffer()
                    nextResultType = .class
                } else if character.unicodeScalars.allSatisfy(allowedIdentifierCharacters.contains) {
                    nextResultBuffer.append(character)
                } else {
                    throw LiteralSyntaxEerror(string: String(character))
                }
            }
            flushCurrentBuffer()
            return WidgetSelector(classes: classes)
        }

        mutating private func flushCurrentBuffer() {
            if let nextResultType = nextResultType {
                switch nextResultType {
                case .class:
                    classes.append(nextResultBuffer)
                }
            }
            nextResultType = nil
            nextResultBuffer = ""
        }
    }
}