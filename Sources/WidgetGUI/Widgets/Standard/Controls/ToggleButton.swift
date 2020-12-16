import GfxMath
import VisualAppBase
import ReactiveProperties

public class ToggleButton<Value: Equatable>: SingleChildWidget, GUIMouseEventConsumer {
  private let leftValue: Value
  private let rightValue: Value
  private let leftChildBuilder: (() -> Widget)?
  private let rightChildBuilder: (() -> Widget)?

  @MutableProperty
  private var state: State = .LeftToggled
  @MutableProperty
  private var value: Value

  @Reference
  private var buttonGraphicSpace: Space
  
  public init(
    leftValue: Value,
    rightValue: Value,
    bind mutableValueBinding: MutablePropertyBinding<Value>,
    leftChild leftChildBuilder: (() -> Widget)? = nil,
    rightChild rightChildBuilder: (() -> Widget)? = nil) {
      self.leftValue = leftValue
      self.rightValue = rightValue
      self._value = mutableValueBinding
      self.leftChildBuilder = leftChildBuilder
      self.rightChildBuilder = rightChildBuilder
      super.init()
      switch value {
      case self.leftValue:
        state = .LeftToggled
      case self.rightValue:
        state = .RightToggled
      default:
        break
      }
  }

  override public func buildChild() -> Widget {
    Row { [unowned self] in
      if let builder = leftChildBuilder { 
        builder()
      } else {
        Text(String(describing: leftValue))
      }
      Row.Item(crossAlignment: .Stretch) {
        Space(DSize2(150, 0)).connect(ref: $buttonGraphicSpace)
      }
      if let builder = rightChildBuilder {
        builder()
      } else {
        Text(String(describing: rightValue))
      }
    }
  }

  override public func renderContent() -> RenderObject? {
    let toggleIndicatorSize = buttonGraphicSpace.size * DVec2(0.5, 1)
    return ContainerRenderObject {
      super.renderContent()

      RenderStyleRenderObject(fillColor: .blue) {
        RectangleRenderObject(buttonGraphicSpace.globalBounds)
      }

      if state == .LeftToggled {
        RenderStyleRenderObject(fillColor: .yellow) {
          RectangleRenderObject(DRect(
            min: buttonGraphicSpace.globalPosition,
            size: toggleIndicatorSize))
        }
      } else if state == .RightToggled {
        RenderStyleRenderObject(fillColor: .yellow) {
          RectangleRenderObject(DRect(
            max: buttonGraphicSpace.globalBounds.max,
            size: toggleIndicatorSize))
        }
      }
    }
  }

  public func consume(_ event: GUIMouseEvent) {
    if let event = event as? GUIMouseButtonClickEvent, event.button == .Left {
      switch state {
      case .LeftToggled:
        state = State.RightToggled
        value = rightValue
      case .RightToggled:
        state = State.LeftToggled
        value = leftValue
      }
      invalidateRenderState()
    }
  }
}

extension ToggleButton {
  public enum State {
    case LeftToggled, RightToggled
  }

  public struct Style: WidgetGUI.Style, BackgroundStyle {
    public var selector: WidgetSelector? = nil
    @StyleProperty
    public var background: Color?

    public init() {}
  }
}

