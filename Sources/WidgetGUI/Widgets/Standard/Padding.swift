import CustomGraphicsMath

public class Padding: SingleChildWidget {
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

    override open func performLayout() {
        let paddingSize = DSize2(padding.left + padding.right, padding.top + padding.bottom)
        let maxSize = constraints!.maxSize - paddingSize
        child.constraints = BoxConstraints(
            minSize: DSize2(min(constraints!.minSize.width, maxSize.width), min(constraints!.minSize.height, maxSize.height)),
            maxSize: maxSize)
        try child.layout()
        child.bounds.topLeft = DVec2(padding.left, padding.top)
        bounds.size = child.bounds.size + paddingSize
    }
}
