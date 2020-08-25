import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

public class Background: SingleChildWidget, BoxWidget {
    private let color: Color
    private let childBuilder: () -> Widget
    
    public init(color: Color, @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        self.color = color
        self.childBuilder = childBuilder
    }

    override public func buildChild() -> Widget {
        childBuilder()
    }

    public func getBoxConfig() -> BoxConfig {
        return (child as! BoxWidget).getBoxConfig()
    }

    override public func performLayout() {
        child.constraints = constraints // legacy

        child.bounds.size = bounds.size

        child.layout()
    }

    override public func renderContent() -> RenderObject? {
        RenderObject.Container {
            RenderObject.RenderStyle(fillColor: color) {
                RenderObject.Rectangle(globalBounds)
            }

            child.render()
        }
    }
}