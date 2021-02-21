public protocol StylableWidget: Widget {
  associatedtype StyleKeys: DefaultStyleKeys
}

extension StylableWidget {
  @discardableResult
  public func with(classes: [String]? = nil, @StylePropertiesBuilder styleProperties build: (Self.StyleKeys.Type) -> StyleProperties) -> Self {
    if let classes = classes {
      self.classes.append(contentsOf: classes)
    }
    self.directStyleProperties.append(build(StyleKeys.self))
    return self
  }
}