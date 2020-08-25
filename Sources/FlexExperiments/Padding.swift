import WidgetGUI
import CustomGraphicsMath

public class Padding: SingleChildWidget, BoxWidget {
    public var padding: Insets

    private var inputChild: Widget

    public init(top: Double, right: Double, bottom: Double, left: Double, @WidgetBuilder child inputChild: () -> Widget) {
        self.padding = Insets(top, right, bottom, left)
        self.inputChild = inputChild()
        super.init()
    }

    public convenience init(all: Double, @WidgetBuilder child inputChild: () -> Widget) {
        self.init(top: all, right: all, bottom: all, left: all, child: inputChild)
    }

    override open func buildChild() -> Widget {
        return inputChild
    }

    public func getBoxConfig() -> BoxConfig {
        var resultConfig = (child as! BoxWidget).getBoxConfig()
        resultConfig.minSize.width += padding.left + padding.right
        resultConfig.minSize.height += padding.top + padding.bottom
        resultConfig.preferredSize.width += padding.left + padding.right
        resultConfig.preferredSize.height += padding.top + padding.bottom
        resultConfig.maxSize.width += padding.left + padding.right
        resultConfig.maxSize.height += padding.top + padding.bottom
        return resultConfig
    }

    override open func performLayout() {      
        child.constraints = constraints // legacy
        
        let paddingSize = DSize2(padding.left + padding.right, padding.top + padding.bottom)
        
        child.bounds.size = bounds.size - paddingSize
        child.bounds.min = DVec2(padding.left, padding.top)

        child.layout()
    }
}

