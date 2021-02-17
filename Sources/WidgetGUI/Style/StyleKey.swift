public protocol StyleKey {
  var asString: String { get }
}

extension RawRepresentable where RawValue == String {
  public var asString: String {
    rawValue
  }
}
extension String: StyleKey {
  public var asString: String {
    self
  }
}