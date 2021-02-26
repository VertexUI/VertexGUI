extension Experimental {
  @_functionBuilder
  public struct StylePropertyValueDefinitionsBuilder<SpecialPropertiesStorage: ExperimentalPartialStylePropertiesStorage> {
    public static func write<S: ExperimentalPartialStylePropertiesStorage, T>(value: T, at keyPath: WritableKeyPath<S, T>, to storage: S) -> S {
      var updated = storage
      updated[keyPath: keyPath] = value
      return updated
    }

    public static func buildDefinition<S: ExperimentalPartialStylePropertiesStorage, T>(keyPath: WritableKeyPath<S, T>, value: StylePropertyValue<T>) -> StylePropertyValueDefinition {
      StylePropertyValueDefinition(
        keyPath: keyPath,
        value: AnyStylePropertyValue(value),
        write: {
          write(value: $1 as! T, at: keyPath, to: $0 as! S)
        }
      )
    }

    public static func buildExpression<T>(_ expression: (WritableKeyPath<SpecialPropertiesStorage, T>, StylePropertyValue<T>)) -> [StylePropertyValueDefinition] {
      [buildDefinition(keyPath: expression.0, value: expression.1)]
    }

    public static func buildExpression<T>(_ expression: (WritableKeyPath<SpecialPropertiesStorage, T>, T)) -> [StylePropertyValueDefinition] {
      [buildDefinition(keyPath: expression.0, value: StylePropertyValue.some(expression.1))]
    }

    public static func buildBlock(_ partials: [[StylePropertyValueDefinition]]) -> [StylePropertyValueDefinition] {
      partials.flatMap { $0 }
    }

    public static func buildBlock(_ partials: [StylePropertyValueDefinition]...) -> [StylePropertyValueDefinition] {
      buildBlock(partials)
    }
  }
}