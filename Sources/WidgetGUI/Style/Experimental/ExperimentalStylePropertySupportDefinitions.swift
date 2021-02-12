extension Experimental {
  public struct StylePropertySupportDefinitions: Sequence, ExpressibleByArrayLiteral {
    public var definitions: [StylePropertySupportDefinition]
    public var definitionsByKey: [String: StylePropertySupportDefinition] {
      definitions.reduce(into: [:]) { $0[$1.key.asString] = $1 }
    }
    public private(set) var source: StylePropertySupportDefinition.Source = .unknown {
      didSet {
        for i in 0..<definitions.count {
          definitions[i].source = source
        }
      }
    }

    /**
    A convenient api for defining supported properties.

    Use it like:

        StylePropertySupportDefinition {
          ("someKey", type: .specific(SomeType.self), default: someValue)
          ("someOtherKey", type: .function({ $0 is SomeType }), value: { $0.property1 == 0 })
        }
     */
    public init(@DefinitionBuilder build: () -> [StylePropertySupportDefinition]) {
      self.init(build())
    }

    public init(_ definitions: [StylePropertySupportDefinition]) {
      self.definitions = definitions
    }

    public init(arrayLiteral elements: StylePropertySupportDefinition...) {
      self.init(elements)
    }

    public init(merge definitions: [StylePropertySupportDefinitions]) throws {
      var byKey = [String: StylePropertySupportDefinition]()
      var merged = [StylePropertySupportDefinition]()

      for definition in definitions.flatMap { $0.definitions } {
        if byKey[definition.key.asString] != nil {
          throw MergingError.duplicateKey(
            key: definition.key.asString,
            sources: [byKey[definition.key.asString]!.source, definition.source])
        }

        byKey[definition.key.asString] = definition
        merged.append(definition)
      }

      self.definitions = merged
    }

    public var count: Int {
      definitions.count
    }

    public func makeIterator() -> Array<StylePropertySupportDefinition>.Iterator {
      definitions.makeIterator()
    }

    public subscript(_ key: StyleKey) -> StylePropertySupportDefinition? {
      definitionsByKey[key.asString]
    }

    mutating public func declaredWith(source: StylePropertySupportDefinition.Source) -> Self {
      self.source = source
      return self
    }

    public func process(_ properties: [Experimental.StyleProperty]) -> (
      validProperties: [Experimental.StyleProperty], results: [String: ValidationResult]
    ) {
      var validationResults = [String: ValidationResult]()
      var validProperties = [Experimental.StyleProperty]()

      for property in properties {
        if let definition = definitionsByKey[property.key.asString] {
          validProperties.append(property)
        } else {
          validationResults[property.key.asString] = .unsupported
        }
      }

      return (validProperties: validProperties, results: validationResults)
    }

    public enum MergingError: Error {
      case duplicateKey(key: String, sources: [StylePropertySupportDefinition.Source])
    }

    @_functionBuilder
    public struct DefinitionBuilder {
      public static func buildExpression(
        _ expression: (
          StyleKey,
          type: StylePropertyValueValidators.TypeValidator,
          value: StylePropertyValueValidators.ValueValidator
        )
      ) -> StylePropertySupportDefinition {
        StylePropertySupportDefinition(
          key: expression.0,
          validators: StylePropertyValueValidators(
            typeValidator: expression.type,
            valueValidator: expression.value))
      }

      public static func buildExpression(
        _ expression: (
          StyleKey,
          type: StylePropertyValueValidators.TypeValidator,
          value: StylePropertyValueValidators.ValueValidator,
          default: StyleValue?
        )
      ) -> StylePropertySupportDefinition {
        StylePropertySupportDefinition(
          key: expression.0,
          validators: StylePropertyValueValidators(
            typeValidator: expression.type,
            valueValidator: expression.value),
          defaultValue: expression.default)
      }

      public static func buildExpression(
        _ expression: (
          StyleKey,
          type: StylePropertyValueValidators.TypeValidator
        )
      ) -> StylePropertySupportDefinition {
        StylePropertySupportDefinition(
          key: expression.0,
          validators: StylePropertyValueValidators(
            typeValidator: expression.type))
      }

      public static func buildExpression(
        _ expression: (
          StyleKey,
          type: StylePropertyValueValidators.TypeValidator,
          default: StyleValue?
        )
      ) -> StylePropertySupportDefinition {
        StylePropertySupportDefinition(
          key: expression.0,
          validators: StylePropertyValueValidators(
            typeValidator: expression.type),
          defaultValue: expression.default)
      }

      public static func buildBlock(_ definitions: StylePropertySupportDefinition...)
        -> [StylePropertySupportDefinition]
      {
        definitions
      }
    }

    public enum ValidationResult {
      case unsupported, invalidType, invalidValue, duplicate
    }
  }
}
