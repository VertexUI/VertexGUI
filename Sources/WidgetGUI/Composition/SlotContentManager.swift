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

  public func buildContent(for data: D) -> DirectContent {
    let content = DirectContent(partials: [])
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

  public func buildContent() -> DirectContent where D == Void {
    buildContent(for: ())
  }

  @available(*, deprecated, message: "use .buildContent() instead")
  public func callAsFunction(_ data: D) -> DirectContent {
    buildContent(for: data)
  }

  @available(*, deprecated, message: "use .buildContent() instead")
  public func callAsFunction() -> DirectContent where D == Void {
    callAsFunction(Void())
  }
}

internal protocol AnySlotContentManager: AnyObject {
  var anySlot: AnySlot { get }
  var anyDefinition: AnySlotContentDefinition? { get set }
}