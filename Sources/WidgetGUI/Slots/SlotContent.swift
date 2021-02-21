@propertyWrapper
public class SlotContent<D>: AnySlotContent {
  public let slot: Slot<D>
  public var anySlot: AnySlot {
    slot
  }

  var anyContainer: AnySlotContentContainer? = nil {
    didSet {
      if oldValue !== anyContainer {
        resolveContent()
      }
    }
  }
  var container: SlotContentContainer<D> {
    anyContainer as! SlotContentContainer<D>
  }

  public var data: D? = nil

  let content = ExpDirectContent(partials: [])
  public var wrappedValue: ExpDirectContent {
    content
  }

  public init(_ slot: Slot<D>) {
    self.slot = slot
  }

  func resolveContent() {
    if ObjectIdentifier(D.self) == ObjectIdentifier(Void.self) {
      content.partials = container.build(Void() as! D)
    }
  }

  /*public func callAsFunction(_ data: D) -> ExpDirectContent {
    container.build(data)
  }

  public func callAsFunction() -> ExpDirectContent where D == Void {
    container.build(Void())
  }*/
}

internal protocol AnySlotContent: class {
  var anySlot: AnySlot { get }
  var anyContainer: AnySlotContentContainer? { get set }
}