import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

public class TaskCompletionButton: Widget {

    private var color: Color

    private let size = DSize2(32, 32)

    public init(color: Color) {

        self.color = color
    }

    override public func getBoxConfig() -> BoxConfig {

        BoxConfig(preferredSize: size)
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        constraints.constrain(size)
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