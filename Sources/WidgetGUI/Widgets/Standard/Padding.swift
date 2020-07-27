import CustomGraphicsMath

public class Padding: SingleChildWidget {
    public var padding: Insets

    private var inputChild: Widget

    public init(padding: Insets, child: Widget) {
        self.padding = padding
        self.inputChild = child
        super.init()
    }

    override open func buildChild() -> Widget {
        return inputChild
    }

    public convenience init(padding: Insets, @WidgetBuilder child: () -> Widget) {
        self.init(padding: padding, child: child())
    }

    override public func layout() throws {
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