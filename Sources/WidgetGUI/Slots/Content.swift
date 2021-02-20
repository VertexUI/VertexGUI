import Events

public protocol ExpContentProtocol: class {
  associatedtype Partial

  var partials: [Partial] { get set }

  var onChanged: EventHandlerManager<Void> { get }
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
      case let .content(nestedContent):
        widgets.append(contentsOf: nestedContent.widgets)
        _ = nestedContent.onChanged {
          print("NESTED CHANGED")
        }
        print("IMPLEMENT RESOLVE UPDATE OF NESTED CONTENT")
      }
    }

    onChanged.invokeHandlers()
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
  var replacementRanges = [Int: Range<Int>]()
  var nestedHandlerRemovers = [() -> ()]()

  public required init(partials: [Partial]) {
    self.partials = partials
    super.init()
    resolve()
  }

  func resolve() {
    for remove in nestedHandlerRemovers {
      remove()
    }
    slotContentDefinitions = []
    replacementRanges = [:]
    nestedHandlerRemovers = []

    for (index, partial) in partials.enumerated() {
      switch partial {
      case let .widget(widget):
        print("IMPLEMENT WIDGET RESOLVE")
      case let .slotContentDefinition(definition):
        slotContentDefinitions.append(definition)
      case let .slottingContent(nestedSlotContent):
        let nestedDefinitions = nestedSlotContent.slotContentDefinitions

        replacementRanges[index] = slotContentDefinitions.count..<(slotContentDefinitions.count + nestedDefinitions.count)

        slotContentDefinitions.append(contentsOf: nestedDefinitions)

        nestedHandlerRemovers.append(nestedSlotContent.onChanged { [unowned self] in
          let nestedDefinitions = nestedSlotContent.slotContentDefinitions
          self.slotContentDefinitions.replaceSubrange(replacementRanges[index]!, with: nestedDefinitions)
          updateReplacementRanges(from: index, deltaLength: nestedDefinitions.count - replacementRanges[index]!.count)
          onChanged.invokeHandlers()
        })
      }
    }

    onChanged.invokeHandlers()
  }

  func updateReplacementRanges(from index: Int, deltaLength: Int) {
    for (rangeIndex, range) in replacementRanges {
      if rangeIndex >= index {
        replacementRanges[rangeIndex] = range.lowerBound..<(range.upperBound + deltaLength)
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

  deinit {
    print("DEINITILAIZED SLOTTING CONTENT")
  }
}

extension ExpSlottingContent {
  public enum Partial {
    case widget(Widget)
    case slotContentDefinition(AnySlotContentContainer)
    case slottingContent(ExpSlottingContent)
  }
}