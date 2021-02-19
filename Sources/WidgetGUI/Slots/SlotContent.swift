@propertyWrapper
public class SlotContent<D>: AnySlotContent {
  public let slot: Slot<D>
  public var anySlot: AnySlot {
    slot
  }

  var anyContainer: AnySlotContentContainer? = nil
  var container: SlotContentContainer<D> {
    anyContainer as! SlotContentContainer<D>
  }
  public var wrappedValue: (D) -> [Widget] {
    (container as! SlotContentContainer<D>).build
  }

  public init(slot: Slot<D>) {
    self.slot = slot
  }

  public func callAsFunction(_ data: D) -> [Widget] {
    container.build(data)
  }

  public func callAsFunction() -> [Widget] where D == Void {
    container.build(Void())
  }
}

internal protocol AnySlotContent: class {
  var anySlot: AnySlot { get }
  var anyContainer: AnySlotContentContainer? { get set }
}