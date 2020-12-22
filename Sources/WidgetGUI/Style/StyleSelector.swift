public struct StyleSelector: Equatable, ExpressibleByStringLiteral {
  public var parts: [StyleSelectorPart]

  public init(parts: [StyleSelectorPart]) {
    self.parts = parts
  }

  public init(parse literal: String) throws {
    self.init(parts: try literal.split(separator: " ").map { try StyleSelectorPart(parse:String($0)) })
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
    var nextWidgetToCheck = widget
    var partsQueuedForParent = [StyleSelectorPart]()
    for (index, part) in parts.enumerated() {
      if part.extendsParent && index != 0 {
        partsQueuedForParent.append(part)
      } else {
        if (partsQueuedForParent + [part]).allSatisfy({ $0.selects(nextWidgetToCheck) }) {
          if let parent = nextWidgetToCheck.parent as? Widget {
            nextWidgetToCheck = parent
            partsQueuedForParent = []
          }
        } else {
          return false
        }
      }
    }
    return true
  }
}