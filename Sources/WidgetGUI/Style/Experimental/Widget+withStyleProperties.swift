extension Widget {
  public func with(@Experimental.StylePropertiesBuilder styleProperties: () -> [Experimental.StyleProperty]) -> Widget {
    experimentalDirectStyleProperties.append(contentsOf: styleProperties())
    return self
  }

  public func with(_ styleProperties: Experimental.StyleProperties) -> Widget {
    experimentalDirectStyleProperties.append(contentsOf: styleProperties.properties)
    return self
  }
}