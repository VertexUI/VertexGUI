public class SlotContentContainer<D>: AnySlotContentContainer {
  var slot: Slot<D> 
  var anySlot: AnySlot {
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

internal protocol AnySlotContentContainer {
  var anySlot: AnySlot { get }
}