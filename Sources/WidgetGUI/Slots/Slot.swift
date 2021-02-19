public class Slot<D>: AnySlot {
  public let key: String
  let dataType: D.Type

  public init(key: String, data: D.Type) {
    self.key = key
    self.dataType = data
  }

  public func callAsFunction(build: @escaping (D) -> [Widget]) -> SlotContentContainer<D> {
    SlotContentContainer(slot: self, build: build)
  }

  public func callAsFunction(build: @escaping () -> [Widget]) -> SlotContentContainer<D> where D == Void {
    SlotContentContainer(slot: self, build: { _ in build() })
  }
}

public protocol AnySlot: class {
  var key: String { get }
}