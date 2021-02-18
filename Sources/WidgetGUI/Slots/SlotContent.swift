@propertyWrapper
public class SlotContent<D>: AnySlotContent {
  public let slot: Slot<D>
  public var anySlot: AnySlot {
    slot
  }

  var container: AnySlotContentContainer? = nil
  public var wrappedValue: (D) -> [Widget] {
    (container as! SlotContentContainer<D>).build
  }

  public init(slot: Slot<D>) {
    self.slot = slot
  }
}

internal protocol AnySlotContent: class {
  var anySlot: AnySlot { get }
  var container: AnySlotContentContainer? { get set }
}