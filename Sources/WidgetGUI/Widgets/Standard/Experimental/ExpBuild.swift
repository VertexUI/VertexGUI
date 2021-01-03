import ExperimentalReactiveProperties

extension Experimental {
  public class Build: Widget {
    private let childBuilder: () -> ChildBuilder.Result

    public init<P1: ReactiveProperty>(_ property: P1, @ChildBuilder child childBuilder: @escaping () -> ChildBuilder.Result) {
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
      let result = childBuilder()
      providedStyles.append(contentsOf: result.styles)
      children = [result.child]
    }
  }
}