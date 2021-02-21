extension Widget {
  public func with(classes: [String]? = nil, @StylePropertiesBuilder styleProperties: (StyleKeys.Type) -> StyleProperties = { _ in [] }) -> Self {
    if let classes = classes {
      self.classes.append(contentsOf: classes)
    }
    self.directStyleProperties.append(styleProperties(StyleKeys.self))
    return self
  }
}