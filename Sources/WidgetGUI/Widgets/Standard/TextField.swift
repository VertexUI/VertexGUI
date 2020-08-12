import CustomGraphicsMath
import VisualAppBase

public class TextField: Widget, GUIMouseEventConsumer {
    override public func performLayout() {
        self.bounds.size = DSize2(100, 40)
    }

    public func consume(_ event: GUIMouseEvent) {
        if event is GUIMouseButtonClickEvent {
            
        }
        print("TEXT FIELD CONSUME EVENT")
    }

    override public func renderContent() -> RenderObject? {
        RenderObject.RenderStyle(fillColor: FixedRenderValue(.Yellow)) {
            RenderObject.Rectangle(globalBounds)
        }
    }
}