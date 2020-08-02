import VisualAppBase
import WidgetGUI
import CustomGraphicsMath

public class TestShapeWidget: Widget {
    override open func performLayout() {
        bounds.size = DSize2(500, 500)
    }

    override open func renderContent() -> RenderObject? {
        return RenderObject.Custom(id: 1212) { renderer in
            try renderer.beginPath()
            try renderer.moveTo(DPoint2(200, 200))
            try renderer.lineTo(DPoint2(150, 0))
            try renderer.lineTo(DPoint2(0, 100))
            try renderer.closePath()
            try renderer.fillColor(.Red)
            try renderer.fill()
        }
    }
}