extension Widget {
  @discardableResult
  public func with(@Experimental.StylePropertiesBuilder styleProperties: (StyleKeys.Type) -> Experimental.StyleProperties) -> Widget {
    experimentalDirectStyleProperties.append(styleProperties(StyleKeys.self))
    return self
  }

  @discardableResult
  public func with(_ styleProperties: Experimental.StyleProperties) -> Widget {
    experimentalDirectStyleProperties.append(styleProperties)
    return self
  }
}