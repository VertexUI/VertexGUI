import GfxMath
import VisualAppBase

public class Spaceholder: SingleChildWidget {
  private let childBuilder: () -> Widget
  @ObservableProperty private var display: Bool
  private var dimension: Dimension

  public init(display: ObservableProperty<Bool>, dimension: Dimension, @WidgetBuilder child childBuilder: @escaping () -> Widget) {
    self.childBuilder = childBuilder
    self.dimension = dimension
    self._display = display
    super.init()
    _ = onDestroy(self.$display.onChanged { [unowned self] _ in
      if dimension != .Both {
        invalidateLayout()
      }
      invalidateRenderState()
    })
  }

  override public func buildChild() -> Widget {
    childBuilder()
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    child.layout(constraints: constraints)
    if display {
      return child.size
    } else {
      switch dimension {
      case .Horizontal:
        return DSize2(child.width, 0)
      case .Vertical:
        return DSize2(0, child.height)
      case .Both:
        return child.size
      }
    }
  }

  override public func renderContent() -> RenderObject? {
    if display {
      return child.render()
    } else {
      return nil
    }
  }
}

extension Spaceholder {
  public enum Dimension {
    case Horizontal, Vertical, Both
  }
}