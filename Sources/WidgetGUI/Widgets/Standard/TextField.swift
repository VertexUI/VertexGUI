import CustomGraphicsMath
import VisualAppBase

public class TextField: Widget, GUIMouseEventConsumer, GUIKeyEventConsumer, GUITextEventConsumer {
    public init() {
        super.init()
        self.focusable = true
    }

    override public func performLayout() {
        self.bounds.size = DSize2(50, 40)
    }

    public func consume(_ event: GUIMouseEvent) {
        if event is GUIMouseButtonClickEvent {
            requestFocus()
            if focused {
                invalidateRenderState()
            }
        }
    }

    public func consume(_ event: GUIKeyEvent) {
        if let event = event as? GUIKeyUpEvent {
        }
    }

    public func consume(_ event: GUITextEvent) {
    }

    override public func renderContent() -> RenderObject? {
        let color: Color = focused ? Color.Yellow : Color.Red
        return RenderObject.RenderStyle(fillColor: FixedRenderValue(color)) {
            RenderObject.Rectangle(globalBounds)
        }
    }
}