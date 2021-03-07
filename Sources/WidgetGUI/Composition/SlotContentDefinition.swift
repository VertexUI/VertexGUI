public class SlotContentDefinition<D>: AnySlotContentDefinition {
  var slot: Slot<D> 
  public var anySlot: AnySlot {
    slot
  }
  var build: (D) -> [DirectContent.Partial]

  public init(slot: Slot<D>, @DirectContentBuilder build: @escaping (D) -> [DirectContent.Partial]) {
    self.slot = slot
    let associatedStyleScope = Widget.activeStyleScope
    self.build = { data in
      Widget.inStyleScope(associatedStyleScope, block: { build(data) })
    }
  }
}

public protocol AnySlotContentDefinition: class {
  var anySlot: AnySlot { get }
}