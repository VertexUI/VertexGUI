import VisualAppBase
import GfxMath
import ReactiveProperties

public class RadioButton: Widget, GUIMouseEventConsumer {
  @MutableProperty
  public var checked: Bool

  //private var onCheckedChanged = WidgetEventHandlerManager<Bool>()

  public init(_ checked: Bool = false) {
    self.checked = checked
    super.init()
    _ = onDestroy(self._checked.onChanged { [unowned self] _ in
      invalidateRenderState()
      //onCheckedChanged.invokeHandlers($0)
    })
  }

  override public func getBoxConfig() -> BoxConfig {
    BoxConfig(size: DSize2(40, 40))
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    boxConfig.preferredSize
  }
  
  override public func renderContent() -> RenderObject? {
    ContainerRenderObject {
      RenderStyleRenderObject(strokeWidth: 2, strokeColor: FixedRenderValue(.black)) {
        EllipsisRenderObject(globalBounds)
      }

      if checked {
        RenderStyleRenderObject(fillColor: .black) {
          EllipsisRenderObject(DRect(center: globalBounds.center, size: globalBounds.size * 0.7))
        }
      }
    }
  }
  
  public func consume(_ event: GUIMouseEvent) {
    if let event = event as? GUIMouseButtonClickEvent {
      checked = !checked
    }
  }
}