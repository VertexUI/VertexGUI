import WidgetGUI
import GfxMath
import VisualAppBase

public class TaskCompletionButton: Widget, GUIMouseEventConsumer {
    private var color: Color
    private let preferredSize = DSize2(32, 32)
    @ObservableProperty private var completed: Bool

    public private(set) var onClick = WidgetEventHandlerManager<GUIMouseButtonClickEvent>()

    public init(_ completed: ObservableProperty<Bool>, color: Color, onClick onClickHandler: ((_ event: GUIMouseButtonClickEvent) -> ())? = nil) {
        self._completed = completed
        self.color = color
        super.init()
        _ = onDestroy(self.$completed.onChanged { [unowned self] _ in
            invalidateRenderState()
        })
        if let handler = onClickHandler {
            _ = onClick.addHandler(handler)
        }
    }

    override public func getBoxConfig() -> BoxConfig {
        BoxConfig(preferredSize: preferredSize)
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
        constraints.constrain(preferredSize)
    }

    public func consume(_ event: GUIMouseEvent) {
        if let event = event as? GUIMouseButtonClickEvent {
            onClick.invokeHandlers(event)
        }
    }

    override public func renderContent() -> RenderObject? {
        RenderObject.Container {
            RenderObject.RenderStyle(strokeWidth: 2, strokeColor: FixedRenderValue(color)) {
                RenderObject.Ellipse(globalBounds)
            }

            if completed {
                RenderObject.RenderStyle(fillColor: color) {
                    RenderObject.Ellipse(DRect(center: globalBounds.center, size: globalBounds.size * 0.8))
                }
            }
        }
    }
}
