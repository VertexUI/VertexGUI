import CombineX

extension Experimental {
  @_functionBuilder
  public struct StylePropertyValueDefinitionsBuilder<W: Widget> {
    public static func buildExpression<V>(_ expression: (KeyPath<Widget, Experimental.DefaultStyleProperty<V>>, StylePropertyValue<V>)) -> [StylePropertyValueDefinition] {
      [StylePropertyValueDefinition(
        keyPath: expression.0,
        value: .constant(AnyStylePropertyValue(expression.1))
      )]
    }

    public static func buildExpression<V>(_ expression: (KeyPath<W, Experimental.SpecialStyleProperty<W, V>>, StylePropertyValue<V>)) -> [StylePropertyValueDefinition] {
      [StylePropertyValueDefinition(
        keyPath: expression.0,
        value: .constant(AnyStylePropertyValue(expression.1))
      )]
    }

    public static func buildExpression<V>(_ expression: (KeyPath<Widget, Experimental.DefaultStyleProperty<V>>, V)) -> [StylePropertyValueDefinition] {
      [StylePropertyValueDefinition(
        keyPath: expression.0,
        value: .constant(.some(expression.1))
      )]
    }

    public static func buildExpression<V>(_ expression: (KeyPath<W, Experimental.SpecialStyleProperty<W, V>>, V)) -> [StylePropertyValueDefinition] {
      [StylePropertyValueDefinition(
        keyPath: expression.0,
        value: .constant(.some(expression.1))
      )]
    }

    public static func buildExpression<V, P: ExperimentalReactiveProperty>(_ expression: (KeyPath<Widget, Experimental.DefaultStyleProperty<V>>, P)) -> [StylePropertyValueDefinition] where P.Value == V {
      [StylePropertyValueDefinition(
        keyPath: expression.0,
        value: .reactive(expression.1.map { AnyStylePropertyValue.some($0) }.eraseToAnyPublisher())
      )]
    }

    public static func buildExpression<V, P: ExperimentalReactiveProperty>(_ expression: (KeyPath<W, Experimental.SpecialStyleProperty<W, V>>, P)) -> [StylePropertyValueDefinition] where P.Value == V {
      [StylePropertyValueDefinition(
        keyPath: expression.0,
        value: .reactive(expression.1.map { AnyStylePropertyValue.some($0) }.eraseToAnyPublisher())
      )]
    }

    public static func buildBlock(_ partials: [[StylePropertyValueDefinition]]) -> [StylePropertyValueDefinition] {
      partials.flatMap { $0 }
    }

    public static func buildBlock(_ partials: [StylePropertyValueDefinition]...) -> [StylePropertyValueDefinition] {
      buildBlock(partials)
    }
  }
}