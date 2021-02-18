public protocol StylableWidget: Widget {
  associatedtype StyleKeys: DefaultStyleKeys
}

extension StylableWidget {
  @discardableResult
  public func with(@StylePropertiesBuilder styleProperties build: (Self.StyleKeys.Type) -> StyleProperties) -> Widget {
    self.directStyleProperties.append(build(StyleKeys.self))
    return self
  }
  
  public func with(classes: [String], styleProperties: (Self.StyleKeys.Type) -> ()) {
    
  }
}