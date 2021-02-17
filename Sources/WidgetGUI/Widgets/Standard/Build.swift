import ReactiveProperties

public class Build: ComposedWidget {
  private let childBuilder: SingleChildContentBuilder.ChildBuilder
  private var ownedProperties = [AnyObject]()

  public init<P: ReactiveProperty>(_ property: P, @BuildChildBuilder child childBuilder: @escaping () -> Widget) {
    self.childBuilder = SingleChildContentBuilder.ChildBuilder(associatedStyleScope: Widget.activeStyleScope, build: childBuilder)
    super.init()
    let ownedProperty = ObservableProperty<P.Value>()
    ownedProperty.bind(property)
    ownedProperties.append(ownedProperty)
    _ = ownedProperty.onHasValueChanged { [unowned self] in
      invalidateBuild()
    }
    _ = ownedProperty.onChanged { [unowned self] _ in
      invalidateBuild()       
    }
  }

  override public func performBuild() {
    rootChild = childBuilder() 
  }

  @_functionBuilder
  public struct BuildChildBuilder {
    public static func buildExpression(_ widget: Widget) -> Widget {
      widget
    }

    public static func buildEither(first widget: Widget) -> Widget {
      widget
    }

    public static func buildEither(second widget: Widget) -> Widget {
      widget
    }

    public static func buildBlock(_ widget: Widget) -> Widget {
      widget
    }
  }
}