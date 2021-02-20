import Events

public protocol ExpContentProtocol: class {
  associatedtype Partial

  var partials: [Partial] { get set }

  var onDestroy: EventHandlerManager<Void> { get }

  init(partials: [Partial])
}

public class ExpContent: EventfulObject {
  public let onChanged = EventHandlerManager<Void>()
  public let onDestroy = EventHandlerManager<Void>()

  deinit {
    onDestroy.invokeHandlers()
    removeAllEventHandlers()
  }
}

public class ExpDirectContent: ExpContent, ExpContentProtocol {
  public var partials: [Partial] = [] {
    didSet {
      resolve()
    }
  }
  public var widgets: [Widget] = []

  public required init(partials: [Partial]) {
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

public class ExpSlottingContent: ExpContent, ExpContentProtocol {
  public var partials: [Partial] = [] {
    didSet {
      resolve()
    }
  }
  public var slotContentDefinitions = [AnySlotContentContainer]()

  public required init(partials: [Partial]) {
    self.partials = partials
    super.init()
    resolve()
  }

  func resolve() {
    slotContentDefinitions = []
    //print("RESOLVE EXP SLOTTING")
    for partial in partials {
      switch partial {
      case let .widget(widget):
        print("IMPLEMENT WIDGET RESOLVE")
      case let .slotContentDefinition(definition):
        slotContentDefinitions.append(definition)
      case let .slottingContent(nestedSlotContent):
        slotContentDefinitions.append(contentsOf: nestedSlotContent.slotContentDefinitions)
        print("IMPLMENT UPDATE NESTED SLOT CONTENT")
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