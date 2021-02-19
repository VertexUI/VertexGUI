public class SlotContentContainer<D>: AnySlotContentContainer {
  var slot: Slot<D> 
  public var anySlot: AnySlot {
    slot
  }
  var build: (D) -> ExpDirectContent
  var associatedStyleScope: UInt

  public init(slot: Slot<D>, @ExpDirectContentBuilder build: @escaping (D) -> ExpDirectContent) {
    self.slot = slot
    self.build = build
    self.associatedStyleScope = Widget.activeStyleScope
  }
}

public protocol AnySlotContentContainer {
  var anySlot: AnySlot { get }
}