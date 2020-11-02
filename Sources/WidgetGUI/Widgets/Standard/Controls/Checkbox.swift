import VisualAppBase
import CustomGraphicsMath

public class Checkbox: Widget, GUIMouseEventConsumer {
  @MutableProperty
  private var checked: Bool

  public let onCheckedChanged = WidgetEventHandlerManager<Bool>()

  private var inset: DVec2 {
    DVec2(size * 0.1)
  }

  // TODO: which type of initializers to keep, and what to do in them?
  // --> where to register invalidateRenderState and onCheckedChanged
  public init(observe observableChecked: ObservableProperty<Bool>) {
    checked = observableChecked.value
    super.init()
    _ = onDestroy(observableChecked.onChanged { [unowned self] in
      if $0 != checked {
        checked = $0
      }
    })
    _ = onDestroy(self._checked.onChanged { [unowned self] in
      invalidateRenderState()
      onCheckedChanged.invokeHandlers($0)
    })
  }

  public init(bind mutableChecked: MutableProperty<Bool>) {
    _checked = mutableChecked
    super.init()
    _ = onDestroy(self._checked.onChanged { [unowned self] in
      invalidateRenderState()
      onCheckedChanged.invokeHandlers($0)
    })
  }

  public init(checked: Bool = false) {
    self.checked = checked
    super.init()
    _ = onDestroy(self._checked.onChanged { [unowned self] in
      invalidateRenderState()
      onCheckedChanged.invokeHandlers($0)
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
      RenderStyleRenderObject(strokeWidth: 2, strokeColor: FixedRenderValue(.Black)) {
        RectangleRenderObject(globalBounds)

        if checked {
          PathRenderObject(Path(
            .Start(DPoint2(globalBounds.min.x, globalBounds.center.y) + inset),
            .Line(DPoint2(globalBounds.center.x, globalBounds.max.y) - inset),
            .Line(DPoint2(globalBounds.max.x - inset.x, globalBounds.min.y + inset.y))))
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