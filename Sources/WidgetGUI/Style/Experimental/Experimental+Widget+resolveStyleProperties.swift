import CXShim

extension Widget {
  internal func resolveStyleProperties() {
    let matchedStylesDefinitions = experimentalMatchedStyles.flatMap { $0.propertyValueDefinitions }
    let mergedDefinitions = mergeDefinitions(matchedStylesDefinitions + experimentalDirectStylePropertyValueDefinitions)

    var resolvedProperties = [ExperimentalAnyStylePropertyProtocol]()

    for definition in mergedDefinitions {
      let definitionWidgetIdentifier = ObjectIdentifier(type(of: definition.keyPath).rootType)

      if let property = self[keyPath: definition.keyPath] as? ExperimentalAnyStylePropertyProtocol {
        resolvedProperties.append(property)

        property.definitionValue = definition.value
      }
    }

    let mirror = Mirror(reflecting: self)
    for child in mirror.allChildren {
      if type(of: child.value) is ExperimentalAnyStylePropertyProtocol.Type {
        let property = child.value as! ExperimentalAnyStylePropertyProtocol

        if resolvedProperties.allSatisfy({ $0 !== property }) {
          property.definitionValue = nil
        }
      }
    }
  }

  fileprivate func mergeDefinitions(_ definitions: [Experimental.StylePropertyValueDefinition]) -> [Experimental.StylePropertyValueDefinition] {
    var merged = [AnyKeyPath: (Int, Experimental.StylePropertyValueDefinition)]()
    for (index, definition) in definitions.enumerated() {
      merged[definition.keyPath] = (index, definition)
    }
    return merged.values.sorted { $0.0 < $1.0 }.map { $0.1 }
  }
}