import ExperimentalReactiveProperties

extension Experimental {
  public class Build: ComposedWidget {
    private let childBuilder: () -> Widget

    public init<P1: ReactiveProperty>(_ property: P1, @BuildChildBuilder child childBuilder: @escaping () -> Widget) {
      self.childBuilder = childBuilder
      super.init()
      _ = property.onHasValueChanged {
        self.invalidateBuild()
      }
      _ = property.onChanged { _ in
        self.invalidateBuild()       
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
}