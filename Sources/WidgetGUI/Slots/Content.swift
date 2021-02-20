import Events

public class ExpContent {
  public let onChanged = EventHandlerManager<Void>()
}

public class ExpDirectContent: ExpContent {
  var partials: [Partial] = [] {
    didSet {
      resolve()
    }
  }
  public var widgets: [Widget] = []

  public init(partials: [Partial]) {
    self.partials = partials
    super.init()
    resolve()
  }

  func resolve() {
    widgets = []
    for partial in partials {
      switch partial {
      case let .widget(widget):
        widgets.append(widget)
      case let .content(content):
        widgets.append(contentsOf: content.widgets)
        print("IMPLEMENT RESOLVE UPDATE OF NESTED CONTENT")
      }
    }
  }
}

extension ExpDirectContent {
  public enum Partial {
    case widget(Widget)
    case content(ExpDirectContent)
  }
}

public class ExpSlottingContent: ExpContent {
  var partials: [Partial] = [] {
    didSet {
      resolve()
    }
  }
  public var slotContentDefinitions = [AnySlotContentContainer]()

  public init(partials: [Partial]) {
    self.partials = partials
    super.init()
    resolve()
  }

  func resolve() {
    slotContentDefinitions = []
    for partial in partials {
      switch partial {
      case let .widget(widget):
        print("IMPLEMENT WIDGET RESOLVE")
      case let .slotContentDefinition(definition):
        slotContentDefinitions.append(definition)
      case let .slottingContent(nestedSlotContent):
        print("IMPLMENT NESTED SLOT CONTENT RESOLVE")
      }
    }
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