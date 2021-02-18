public class Slot<D>: AnySlot {
  public let key: String
  let dataType: D.Type

  public init(key: String, data: D.Type) {
    self.key = key
    self.dataType = data
  }
}

public protocol AnySlot: class {
  var key: String { get }
}