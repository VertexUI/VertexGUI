public protocol PseudoClass {
  var asString: String { get }
}

extension PseudoClass where Self: RawRepresentable, Self.RawValue == String {
  public var asString: String {
    self.rawValue
  }
}

extension String: PseudoClass {}