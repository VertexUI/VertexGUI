public class StyleParser {
  public init() {}

  public func parse(_ source: String) throws -> [Style] {
    var selector: StyleSelector
    var properties = [StyleProperty]()

    let lines = source.split(separator: "\n")

    selector = try StyleSelector(parse: String(lines[0][lines[0].startIndex...lines[0].index(of: " ")!]))

    for line in lines[1...] {
      let parts = line.split(separator: ":")
      
      let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
      
      let valueLiteral = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
      var value: StyleValue?
      for valueParser in valueParsers {
        if valueParser.test(valueLiteral) {
          value = valueParser.parse(valueLiteral)
          if value != nil {
            break
          }
        }
      }

      guard let unwrappedValue = value else {
        throw ParserError.invalidValueLiteral
      }

      properties.append(StyleProperty(key: key, value: unwrappedValue))
    }

    return [Style(selector: selector, properties: StyleProperties(properties), children: [])]
  }

  public var valueParsers = [
    ValueParser(test: { _ in
      true
    }, parse: {
      Double($0)
    })
  ]

  public struct ValueParser {
    public let test: (String) -> Bool
    public let parse: (String) -> StyleValue?

    public init(test: @escaping (String) -> Bool, parse: @escaping (String) -> StyleValue?) {
      self.test = test
      self.parse = parse
    }
  }

  public enum ParserError: Error {
    case invalidValueLiteral
  }
}