extension Experimental {
  public struct StyleProperty {
    public var key: StyleKey
    public var value: StyleValue
    public typealias SpecificInitTuple = (StyleKey, StyleValue)

    public init(key: StyleKey, value: StyleValue) {
      self.key = key
      self.value = value
    }
  }
}