public protocol ExperimentalStylableWidget: Widget {
  associatedtype StyleKeys: ExperimentalDefaultStyleKeys
}

extension ExperimentalStylableWidget {
  @discardableResult
  public func with(@Experimental.StylePropertiesBuilder styleProperties build: (Self.StyleKeys.Type) -> Experimental.StyleProperties) -> Widget {
    self.experimentalDirectStyleProperties.append(build(StyleKeys.self))
    return self
  }
}