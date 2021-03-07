import CXShim

extension Widget {
  internal func resolveStyleProperties() {
    let sortedMatchedStyles = matchedStyles.sorted {
      if ($0.treePath == nil && $1.treePath != nil) || ($0.treePath == nil && $1.treePath == nil) {
        return true
      } else if $0.treePath != nil && $1.treePath == nil {
        return false
      } else {
        return $0.treePath! < $1.treePath!
      }
    }

    let matchedStylesDefinitions = sortedMatchedStyles.flatMap { $0.propertyValueDefinitions }
    let mergedDefinitions = mergeDefinitions(matchedStylesDefinitions + DirectStylePropertyValueDefinitions)

    var resolvedProperties = [AnyStylePropertyProtocol]()

    for definition in mergedDefinitions {
      let definitionWidgetIdentifier = ObjectIdentifier(type(of: definition.keyPath).rootType)

      if let property = self[keyPath: definition.keyPath] as? AnyStylePropertyProtocol {
        resolvedProperties.append(property)

        property.definitionValue = definition.value
      }
    }

    let mirror = Mirror(reflecting: self)
    for child in mirror.allChildren {
      if type(of: child.value) is AnyStylePropertyProtocol.Type {
        let property = child.value as! AnyStylePropertyProtocol

        if resolvedProperties.allSatisfy({ $0 !== property }) {
          property.definitionValue = nil
        }
      }
    }
  }

  fileprivate func mergeDefinitions(_ definitions: [StylePropertyValueDefinition]) -> [StylePropertyValueDefinition] {
    var merged = [AnyKeyPath: (Int, StylePropertyValueDefinition)]()
    for (index, definition) in definitions.enumerated() {
      merged[definition.keyPath] = (index, definition)
    }
    return merged.values.sorted { $0.0 < $1.0 }.map { $0.1 }
  }
}