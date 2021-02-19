public class SlotContent<D>: AnySlotContent {
  public let slot: Slot<D>
  public var anySlot: AnySlot {
    slot
  }

  var anyContainer: AnySlotContentContainer? = nil
  var container: SlotContentContainer<D> {
    anyContainer as! SlotContentContainer<D>
  }

  public init(slot: Slot<D>) {
    self.slot = slot
  }

  public func callAsFunction(_ data: D) -> ExpDirectContent {
    container.build(data)
  }

  public func callAsFunction() -> ExpDirectContent where D == Void {
    container.build(Void())
  }
}

internal protocol AnySlotContent: class {
  var anySlot: AnySlot { get }
  var anyContainer: AnySlotContentContainer? { get set }
}