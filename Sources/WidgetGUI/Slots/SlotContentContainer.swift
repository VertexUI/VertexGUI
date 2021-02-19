public class SlotContentContainer<D>: AnySlotContentContainer {
  var slot: Slot<D> 
  public var anySlot: AnySlot {
    slot
  }
  var build: (D) -> [Widget]
  var associatedStyleScope: UInt

  public init(slot: Slot<D>, build: @escaping (D) -> [Widget]) {
    self.slot = slot
    self.build = build
    self.associatedStyleScope = Widget.activeStyleScope
  }
}

public protocol AnySlotContentContainer {
  var anySlot: AnySlot { get }
}