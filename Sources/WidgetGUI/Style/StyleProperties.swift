public struct StyleProperties: Sequence, ExpressibleByArrayLiteral {
  public var properties: [StyleProperty]

  public init<K>(_ keys: K.Type, @StylePropertiesBuilder _ build: (K.Type) -> StyleProperties) {
    self = build(keys)
  }

  public init<W: StylableWidget>(_ widget: W.Type, @StylePropertiesBuilder _ build: (W.StyleKeys.Type) -> StyleProperties) {
    self = build(widget.StyleKeys)
  }

  public init(@StylePropertiesBuilder _ build: () -> StyleProperties) {
    self = build()
  }

  public init(_ properties: [StyleProperty]) {
    self.properties = properties
  }

  public init(arrayLiteral properties: StyleProperty...) {
    self.init(properties)
  }

  public func makeIterator() -> Array<StyleProperty>.Iterator {
    properties.makeIterator()
  }

  public var count: Int {
    properties.count
  }
}