extension Experimental {
  public struct StyleProperties {
    public var properties: [Experimental.StyleProperty]

    public init<K>(_ keys: K.Type, @StylePropertiesBuilder _ build: (K.Type) -> [Experimental.StyleProperty]) {
      self.properties = build(keys)
    }

    public init<W: ExperimentalStylableWidget>(_ widget: W.Type, @StylePropertiesBuilder _ build: (W.StyleKeys.Type) -> [Experimental.StyleProperty]) {
      self.properties = build(widget.StyleKeys)
    }
  }
}