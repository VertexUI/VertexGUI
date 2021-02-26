extension Widget {
  internal func resolveStyleProperties() {
    let mergedDefinitions = experimentalDirectStylePropertyValueDefinitions

    for definition in mergedDefinitions {
      let definitionWidgetIdentifier = ObjectIdentifier(type(of: definition.keyPath).rootType)
      if definitionWidgetIdentifier == ObjectIdentifier(Self.self) {
        switch definition.value {
        case .inherit:
          print("IMPLEMENT INHERIT")
        case let .some(value):
          (self[keyPath: definition.keyPath] as? ExperimentalAnyStylePropertyProtocol)?.anyValue = value
        }
      }
    }
  }
}