import CustomGraphicsMath

public class Padding: SingleChildWidget {

    public var padding: Insets

    private var inputChild: Widget

    public init(top: Double = 0, right: Double = 0, bottom: Double = 0, left: Double = 0, @WidgetBuilder child inputChild: () -> Widget) {

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

    override public func getBoxConfig() -> BoxConfig {

        var resultConfig = child.boxConfig
        
        resultConfig.minSize.width += padding.left + padding.right

        resultConfig.minSize.height += padding.top + padding.bottom

        resultConfig.preferredSize.width += padding.left + padding.right

        resultConfig.preferredSize.height += padding.top + padding.bottom

        resultConfig.maxSize.width += padding.left + padding.right

        resultConfig.maxSize.height += padding.top + padding.bottom

        return resultConfig
    }

    override open func performLayout(constraints: BoxConstraints) -> DSize2 {      

        let paddingSize = DSize2(padding.left + padding.right, padding.top + padding.bottom)
        
        child.layout(constraints: BoxConstraints(
            minSize: max(DSize2.zero, constraints.minSize - paddingSize),
            maxSize: max(DSize2.zero, constraints.maxSize - paddingSize)
        ))

        child.bounds.min = DVec2(padding.left, padding.top)

        return constraints.constrain(child.bounds.size + paddingSize)
    }
}

