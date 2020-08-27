import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

public class TaskCompletionButton: Widget {

    private var color: Color

    public init(color: Color) {

        self.color = color
    }

    override public func getBoxConfig() -> BoxConfig {

        BoxConfig(preferredSize: DSize2(32, 32))
    }

    override public func performLayout() {

    }

    override public func renderContent() -> RenderObject? {

        RenderObject.Container {
            
            RenderObject.RenderStyle(strokeWidth: 2, strokeColor: FixedRenderValue(color)) {

                RenderObject.Ellipse(globalBounds)
            }

            RenderObject.RenderStyle(fillColor: color) {

                RenderObject.Ellipse(DRect(center: globalBounds.center, size: globalBounds.size * 0.8))
            }
        }
    }
}