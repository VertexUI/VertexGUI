public class FocusScope: SingleChildWidget {
  private let childBuilder: () -> Widget
  override open var focusContext: FocusContext {
    get {
      _inheritedFocusContext!
    }

    set {
      _inheritedFocusContext = newValue
    }
  }
  private var _inheritedFocusContext: FocusContext?
  private var sharedFocusContext = FocusContext()

  public init(@WidgetBuilder child childBuilder: @escaping () -> Widget) {
    self.childBuilder = childBuilder
  }

  override public func buildChild() -> Widget {
    childBuilder()
  }

  override public func mountChild(_ child: Widget, with context: ReplacementContext? = nil) {
    super.mountChild(child, with: context)
    child.focusContext = sharedFocusContext
  }
}