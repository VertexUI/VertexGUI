import Events

public class SlotContentManager<D>: AnySlotContent, EventfulObject {
  public let slot: Slot<D>
  public var anySlot: AnySlot {
    slot
  }

  var anyContainer: AnySlotContentContainer? = nil {
    didSet {
      if oldValue !== anyContainer {
        onContainerChanged.invokeHandlers()
      }
    }
  }
  var container: SlotContentContainer<D>? {
    anyContainer as? SlotContentContainer<D>
  }

  let onContainerChanged = EventHandlerManager<Void>()

  public init(_ slot: Slot<D>) {
    self.slot = slot
  }

  public func callAsFunction(_ data: D) -> ExpDirectContent {
    let content = ExpDirectContent(partials: [])
    if let container = container {
      content.partials = container.build(data)
    }
    _ = content.onDestroy(onContainerChanged { [unowned self, unowned content] in
      if let container = container {
        content.partials = container.build(data)
      } else {
        content.partials = []
      }
    })
    return content
  }

  public func callAsFunction() -> ExpDirectContent where D == Void {
    callAsFunction(Void())
  }
}

internal protocol AnySlotContent: class {
  var anySlot: AnySlot { get }
  var anyContainer: AnySlotContentContainer? { get set }
}