public protocol StyleKey {
  var asString: String { get }
}

extension String: StyleKey {
  public var asString: String {
    self
  }
}