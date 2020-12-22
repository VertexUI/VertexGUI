public struct StyleSelector: Equatable, ExpressibleByStringLiteral {
  public var parts: [StyleSelectorPart]

  public init(_ parts: [StyleSelectorPart]) {
    self.parts = parts
  }

  public init(parse literal: String) throws {
    self.init(try literal.split(separator: " ").map { try StyleSelectorPart(parse:String($0)) })
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
}