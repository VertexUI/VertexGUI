import Events

public class ExpContent {
  public let onChanged = EventHandlerManager<Void>()
}

public class ExpDirectContent {
  var partials: [Partial] = [] {
    didSet {
      resolve()
    }
  }
  public var widgets: [Widget] = []

  public init(partials: [Partial]) {
    self.partials = partials
  }

  func resolve() {

  }
}

extension ExpDirectContent {
  public enum Partial {
    case widget(Widget)
    case content(ExpDirectContent)
  }
}

public class ExpSlottingContent {
  var partials: [Partial] = [] {
    didSet {
      resolve()
    }
  }
  public var slotContentDefinitions = [AnySlotContentContainer]()

  public init(partials: [Partial]) {
    self.partials = partials
  }

  func resolve() {
    
  }

  public func getSlotContentDefinition(for slot: AnySlot) -> AnySlotContentContainer? {
    for definition in slotContentDefinitions {
      if definition.anySlot === slot {
        return definition
      }
    }
    return nil
  }
}

extension ExpSlottingContent {
  public enum Partial {
    case widget(Widget)
    case slotContentDefinition(AnySlotContentContainer)
    case slottingContent(ExpSlottingContent)
  }
}