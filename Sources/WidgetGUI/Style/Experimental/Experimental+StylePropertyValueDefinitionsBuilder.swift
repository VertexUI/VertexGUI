import CombineX

extension Experimental {
  @_functionBuilder
  public struct StylePropertyValueDefinitionsBuilder<W: Widget> {
    public static func write<W: Widget, T>(value: T, at keyPath: WritableKeyPath<W, T>, to widget: W) -> W {
      var updated = widget
      updated[keyPath: keyPath] = value
      return updated
    }

    /*public static func buildDefinition<W: Widget, T>(keyPath: WritableKeyPath<W, T>, value: StylePropertyValue<T>) -> StylePropertyValueDefinition {
      StylePropertyValueDefinition(
        keyPath: keyPath,
        value: AnyStylePropertyValue(value),
        write: {
          write(value: $1 as! T, at: keyPath, to: $0 as! W)
        }
      )
    }*/

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
      return [StylePropertyValueDefinition(
        keyPath: expression.0,
        value: .reactive(expression.1.map { AnyStylePropertyValue.some($0) }.eraseToAnyPublisher())
      )]
    }

    /*public static func buildExpression<V, P: ExperimentalReactiveProperty>(_ expression: (KeyPath<W, Experimental.SpecialStyleProperty<W, V>>, P)) -> [StylePropertyValueDefinition] where P.Value == V {
      [StylePropertyValueDefinition(
        keyPath: expression.0,
        value: .reactive(TypelessReactiveProperty(expression.1))
      )]
    }*/

    public static func buildBlock(_ partials: [[StylePropertyValueDefinition]]) -> [StylePropertyValueDefinition] {
      partials.flatMap { $0 }
    }

    public static func buildBlock(_ partials: [StylePropertyValueDefinition]...) -> [StylePropertyValueDefinition] {
      buildBlock(partials)
    }
  }
}