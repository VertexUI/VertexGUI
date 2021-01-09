public protocol ExperimentalStylableWidget: Widget {
  associatedtype StyleKeys: ExperimentalDefaultStyleKeys
}

extension ExperimentalStylableWidget {
  public func with(@Experimental.StylePropertiesBuilder styleProperties build: (Self.StyleKeys.Type) -> [Experimental.StyleProperty]) -> Widget {
    self.experimentalDirectStyleProperties.append(contentsOf: build(StyleKeys.self))
    return self
  }
}