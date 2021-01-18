extension Widget {
  public func updateAppliedStyleProperties() {
    var result = [String: Experimental.StyleProperty]()

    for style in experimentalMatchedStyles {
      for property in style.properties {
        result[property.key.asString] = property
      }
    }

    for property in experimentalDirectStyleProperties {
      //result[property.key.asString] = property
    }

    // TODO: check whether properties have the same order as in matched styles
    experimentalAppliedStyleProperties = Array(result.values)
  }
}