import GfxMath

extension Experimental {
  public struct DefaultStylePropertiesStorage: ExperimentalPartialStylePropertiesStorage {
    public var foreground: Color = .black
    public var background: Color = .transparent
    public var textTransform: TextTransform? = nil

    public init() {}
  }
}

extension Experimental.StylePropertyValueDefinitionsBuilder {
  public static func buildExpression<T>(_ expression: (WritableKeyPath<Experimental.DefaultStylePropertiesStorage, T>, Experimental.StylePropertyValue<T>)) -> [Experimental.StylePropertyValueDefinition] {
    [buildDefinition(keyPath: expression.0, value: expression.1)]
  }

  public static func buildExpression<T>(_ expression: (WritableKeyPath<Experimental.DefaultStylePropertiesStorage, T>, T)) -> [Experimental.StylePropertyValueDefinition] {
    [buildDefinition(keyPath: expression.0, value: Experimental.StylePropertyValue.some(expression.1))]
  }
}

extension Experimental.StylePropertyValues {
  public subscript<T>(keyPath: KeyPath<Experimental.DefaultStylePropertiesStorage, T>) -> T {
    (storages[ObjectIdentifier(Experimental.DefaultStylePropertiesStorage.self)] as! Experimental.DefaultStylePropertiesStorage)[keyPath: keyPath]
  }
}