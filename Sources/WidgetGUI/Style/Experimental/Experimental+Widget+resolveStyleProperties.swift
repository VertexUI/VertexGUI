extension Widget {
  fileprivate func mergeDefinitions(_ definitions: [Experimental.StylePropertyValueDefinition]) -> [Experimental.StylePropertyValueDefinition] {
    var merged = [AnyKeyPath: (Int, Experimental.StylePropertyValueDefinition)]()
    for (index, definition) in definitions.enumerated() {
      merged[definition.keyPath] = (index, definition)
    }
    return merged.values.sorted { $0.0 < $1.0 }.map { $0.1 }
  }

  internal func resolveStyleProperties() {
    let matchedStylesDefinitions = experimentalMatchedStyles.flatMap { $0.propertyValueDefinitions }
    let mergedDefinitions = mergeDefinitions(matchedStylesDefinitions + experimentalDirectStylePropertyValueDefinitions)

    for definition in mergedDefinitions {
      let definitionWidgetIdentifier = ObjectIdentifier(type(of: definition.keyPath).rootType)
      //if definitionWidgetIdentifier == ObjectIdentifier(Self.self) {
        switch definition.value {
        case .inherit:
          print("IMPLEMENT INHERIT")
        case let .some(value):
          (self[keyPath: definition.keyPath] as? ExperimentalAnyStylePropertyProtocol)?.anyValue = value
        }
      //}
    }
  }
}