public struct StyleSelector: Equatable, Sequence, ExpressibleByStringLiteral {
  public var source: String?
  public var parts: [StyleSelectorPart]

  public init(_ parts: [StyleSelectorPart]) {
    // TODO: maybe this should be a throwing function?
    self.parts = try! StyleSelector.simplify(parts: parts)
  }

  public init(parse literal: String) throws {
    self.init(try literal.split(separator: " ").map { try StyleSelectorPart(parse:String($0)) })
    self.source = literal
  }

  public init(stringLiteral: String) {
    try! self.init(parse: stringLiteral)
  }

  public var extendsParent: Bool {
    if let first = parts.first {
      return first.extendsParent
    } 
    return false
  }

  public func makeIterator() -> Array<StyleSelectorPart>.Iterator {
    parts.makeIterator()
  }

  public var partCount: Int {
    parts.count
  }

  public subscript(part index: Int) -> StyleSelectorPart {
    parts[index]
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.parts == rhs.parts
  }

  /**
  Checks whether the selector parts match starting from the last selector part and the given widget and going up the Widget tree checking the widgets parents.
  Selector parts that have `.extendsParents == true` are merged with their parents.
  Whether the first selector part is an extension on it's parent (and therefore the whole selector is) or not is ignored. Logic should be applied
  before calling this function to make sure that in case the StyleSelector is an extension on it's parent,
  the parent StyleSelectors that are managed by outside logic are checked as well.
  */
  public func selects(_ widget: Widget) -> Bool {
    // TODO: performance could be improved if each Widget stores it's own full selector path already
    var nextWidgetToCheck = Optional(widget)
    var partsQueuedForParent = [StyleSelectorPart]()
    for (index, part) in parts.reversed().enumerated() {
      if part.extendsParent && index != parts.count - 1 {
        partsQueuedForParent.append(part)
      } else {
        var matched = false
        while !matched, let currentWidgetToCheck = nextWidgetToCheck {
          if (partsQueuedForParent + [part]).allSatisfy({ $0.selects(currentWidgetToCheck) }) {
            partsQueuedForParent = []
            matched = true
            nextWidgetToCheck = currentWidgetToCheck.parent as? Widget 
            break
          }
          nextWidgetToCheck = currentWidgetToCheck.parent as? Widget 
        }

        if !matched {
          return false
        }
      }
    }
    return true
  }

  /** 
  Merges parts referencing their parent with their parent.
  */
  private static func simplify(parts: [StyleSelectorPart]) throws -> [StyleSelectorPart] {
    var merged = [StyleSelectorPart]()

    for part in parts {
      if part.extendsParent && merged.count > 0 {
        var previous = merged[merged.count - 1]

        if previous.opensScope && !part.opensScope {
          throw PartMergingError.opensScopeOverwrite(previous, part)
        } else if !previous.opensScope && part.opensScope {
          previous.opensScope = true
        }

        previous.classes.append(contentsOf: part.classes)

        previous.pseudoClasses.append(contentsOf: part.pseudoClasses)

        if (previous.type != nil || previous.typeName != nil) &&
          (part.type != nil || part.typeName != nil) {
            throw PartMergingError.typeOverwrite(previous, part)
        } else if part.type != nil {
          previous.type = part.type
        } else if part.typeName != nil {
          previous.typeName = part.typeName
        }

        merged[merged.count - 1] = previous
      } else {
        merged.append(part)
      }
    }

    return merged
  }

  public enum PartMergingError: Error {
    case typeOverwrite(StyleSelectorPart, StyleSelectorPart)
    case opensScopeOverwrite(StyleSelectorPart, StyleSelectorPart)
  }
}