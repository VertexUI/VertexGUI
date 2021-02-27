extension Widget {
  internal func resolveStyleProperties() {
    let matchedStylesDefinitions = experimentalMatchedStyles.flatMap { $0.propertyValueDefinitions }
    let mergedDefinitions = mergeDefinitions(matchedStylesDefinitions + experimentalDirectStylePropertyValueDefinitions)

    var resolvedProperties = [ExperimentalAnyStylePropertyProtocol]()

    for definition in mergedDefinitions {
      let definitionWidgetIdentifier = ObjectIdentifier(type(of: definition.keyPath).rootType)

      if let property = self[keyPath: definition.keyPath] as? ExperimentalAnyStylePropertyProtocol {
        resolvedProperties.append(property)

        property.anyStyleValue = definition.value
        /*switch definition.value {
        case .inherit:
          print("IMPLEMENT INHERIT")
        case let .some(value):
          (self[keyPath: definition.keyPath] as? ExperimentalAnyStylePropertyProtocol)?.anyValue = value
        }*/
      }
    }

    let mirror = Mirror(reflecting: self)
    for child in mirror.allChildren {
      if type(of: child.value) is ExperimentalAnyStylePropertyProtocol.Type {
        let property = child.value as! ExperimentalAnyStylePropertyProtocol

        if resolvedProperties.allSatisfy({ $0 !== property }) {
          property.anyStyleValue = nil
          //property.anyStyleValue = definition.value
          /*if let defaultValue = property.anyDefaultValue {
            switch defaultValue {
            case .inherit:
              print("RESOLVE IHERIT")
              if let value = inheritOrNot(property: property) {
                property.anyValue = value
              }
            case let .some(value):
              property.anyValue = value
            }
          }*/
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

  /*fileprivate func inheritOrNot(property: Experimental.AnyStyleProperty) -> Any? {
    if let parent = parent as? Widget {
      return property.resolveSelfOn(widget: parent)?.anyValue
    }

    return nil
  }*/
}