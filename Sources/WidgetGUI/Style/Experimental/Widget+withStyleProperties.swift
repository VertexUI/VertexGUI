extension Widget {
  public func with(@Experimental.StylePropertiesBuilder styleProperties: (StyleKeys.Type) -> [Experimental.StyleProperty]) -> Widget {
    experimentalDirectStyleProperties.append(contentsOf: styleProperties(StyleKeys.self))
    return self
  }

  public func with(_ styleProperties: Experimental.StyleProperties) -> Widget {
    experimentalDirectStyleProperties.append(contentsOf: styleProperties.properties)
    return self
  }
}