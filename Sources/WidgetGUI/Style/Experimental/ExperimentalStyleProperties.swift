extension Experimental {
  public struct StyleProperties: Sequence, ExpressibleByArrayLiteral {
    public var properties: [Experimental.StyleProperty]

    public init<K>(_ keys: K.Type, @StylePropertiesBuilder _ build: (K.Type) -> Experimental.StyleProperties) {
      self = build(keys)
    }

    public init<W: ExperimentalStylableWidget>(_ widget: W.Type, @StylePropertiesBuilder _ build: (W.StyleKeys.Type) -> Experimental.StyleProperties) {
      self = build(widget.StyleKeys)
    }

    public init(@StylePropertiesBuilder _ build: () -> Experimental.StyleProperties) {
      self = build()
    }

    public init(_ properties: [Experimental.StyleProperty]) {
      self.properties = properties
    }

    public init(arrayLiteral properties: Experimental.StyleProperty...) {
      self.init(properties)
    }

    public func makeIterator() -> Array<Experimental.StyleProperty>.Iterator {
      properties.makeIterator()
    }

    public var count: Int {
      properties.count
    }
  }
}