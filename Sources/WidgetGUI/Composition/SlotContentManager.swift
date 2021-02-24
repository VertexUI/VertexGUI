import Events

public class SlotContentManager<D>: AnySlotContentManager, EventfulObject {
  public let slot: Slot<D>
  public var anySlot: AnySlot {
    slot
  }

  var anyDefinition: AnySlotContentDefinition? = nil {
    didSet {
      if oldValue !== anyDefinition {
        onDefinitionChanged.invokeHandlers()
      }
    }
  }
  var definition: SlotContentDefinition<D>? {
    anyDefinition as? SlotContentDefinition<D>
  }

  let onDefinitionChanged = EventHandlerManager<Void>()

  public init(_ slot: Slot<D>) {
    self.slot = slot
  }

  public func callAsFunction(_ data: D) -> ExpDirectContent {
    let content = ExpDirectContent(partials: [])
    if let definition = definition {
      content.partials = definition.build(data)
    }
    _ = content.onDestroy(onDefinitionChanged { [unowned self, unowned content] in
      if let definition = definition {
        content.partials = definition.build(data)
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

internal protocol AnySlotContentManager: class {
  var anySlot: AnySlot { get }
  var anyDefinition: AnySlotContentDefinition? { get set }
}