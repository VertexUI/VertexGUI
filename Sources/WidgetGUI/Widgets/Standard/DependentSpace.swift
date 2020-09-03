import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

// TODO: maybe can use CalculatedSize for that / maybe have a general DependentConfiguration Widget that updates Widgets on other Widget updates
public class DependentSpace: Widget {

    private let dependency: Widget

    private let calculate: (_ dependency: Widget) -> DSize2

    public init(dependency: Widget, calculate: @escaping (_ dependency: Widget) -> DSize2) {

        self.dependency = dependency

        self.calculate = calculate

        super.init()

        _ = onDestroy(dependency.onBoundsChanged { [unowned self] _ in
            
            invalidateBoxConfig()
        })
    }

    override public func getBoxConfig() -> BoxConfig {

        let size = calculate(dependency)

        return BoxConfig(preferredSize: size, minSize: size, maxSize: size)
    }

    override public func performLayout() {

    }

    override public func renderContent() -> RenderObject? {

        nil
    }
}