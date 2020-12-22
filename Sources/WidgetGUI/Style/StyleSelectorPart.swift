import Foundation

public struct StyleSelectorPart: Equatable, Hashable, ExpressibleByStringLiteral {
    public var extendsParent: Bool

    public var typeName: String? {
        willSet {
            if newValue != nil && type != nil {
                fatalError("can only set one of type or typeName")
            }
        }
    }
    public var type: Any.Type? {
        willSet {
            if newValue != nil && typeName != nil {
                fatalError("can only set one of type or typeName")
            }
        }
    }
    public var classes: [String]
    public var pseudoClasses: [String]

    public init() {
        self.extendsParent = false
        self.classes = []
        self.pseudoClasses = []
    }

    public init(extendsParent: Bool = false, typeName: String? = nil, classes: [String] = [], pseudoClasses: [String] = []) {
        self.extendsParent = extendsParent
        self.typeName = typeName
        self.classes = classes
        self.pseudoClasses = pseudoClasses
    }

    public init(extendsParent: Bool = false, type: Any.Type? = nil, classes: [String] = [], pseudoClasses: [String] = []) {
        self.extendsParent = extendsParent
        self.type = type
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
    - Returns: `true` if type or typeName are either not set or match the widget and classes, pseudoClasses fully or partially match the given widget. Whereby the Widget can contain elements that are not in the selector, but the selector cannot contain elements that are not in the Widget.
    An empty part always selects any widget (returns `true`).
    Otherwise returns `false`.
    */
    public func selects(_ widget: Widget) -> Bool {
        if let typeName = typeName, widget.name != typeName {
            return false
        }

        if let type = type, ObjectIdentifier(type) != ObjectIdentifier(Swift.type(of: widget)) {
            return false
        }

        if widget.classes.count < classes.count || widget.pseudoClasses.count < pseudoClasses.count {
            return false
        }

        return classes.allSatisfy(widget.classes.contains) && pseudoClasses.allSatisfy(widget.pseudoClasses.contains)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.extendsParent == rhs.extendsParent && 
        lhs.classes.count == rhs.classes.count &&
        lhs.pseudoClasses.count == rhs.pseudoClasses.count && 
        lhs.classes.sorted() == rhs.classes.sorted() && 
        lhs.pseudoClasses.sorted() == rhs.pseudoClasses.sorted()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(extendsParent)
        hasher.combine(typeName)
        hasher.combine(String(describing: type))
        hasher.combine(classes)
        hasher.combine(pseudoClasses)
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
        case type, `class`, pseudoClass
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
                    if nextResultType == nil {
                        nextResultType = .type
                    }
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
                case .type:
                    result.typeName = nextResultBuffer
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