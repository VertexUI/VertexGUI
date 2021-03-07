public class Slot<D>: AnySlot {
  public let key: String
  let dataType: D.Type

  public init(key: String, data: D.Type) {
    self.key = key
    self.dataType = data
  }

  public func callAsFunction(@DirectContentBuilder build: @escaping (D) -> [DirectContent.Partial]) -> SlotContentDefinition<D> {
    SlotContentDefinition(slot: self, build: build)
  }

  /*public func callAsFunction(@DirectContentBuilder build: @escaping () -> DirectContent) -> SlotContentDefinition<D> where D == Void {
    SlotContentDefinition(slot: self, build: { _ in build() })
  }*/
}

public protocol AnySlot: class {
  var key: String { get }
}