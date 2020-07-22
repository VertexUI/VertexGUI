import CustomGraphicsMath

public class Padding: SingleChildWidget {
    public var padding: Insets

    public init(padding: Insets, child: Widget) {
        self.padding = padding
        super.init(child: child)
    }

    public convenience init(padding: Insets, @WidgetBuilder child: () -> Widget) {
        self.init(padding: padding, child: child())
    }

    override public func layout(fromChild: Bool) throws {
        let paddingSize = DSize2(padding.left + padding.right, padding.top + padding.bottom)
        let maxSize = constraints!.maxSize - paddingSize
        child.constraints = BoxConstraints(
            minSize: DSize2(min(constraints!.minSize.width, maxSize.width), min(constraints!.minSize.height, maxSize.height)),
            maxSize: maxSize)
        try child.layout()
        child.bounds.topLeft = DVec2(padding.left, padding.top)
        bounds.size = child.bounds.size + paddingSize

        /*child.bounds.topLeft = DPoint2(padding.left, padding.top)
        try child.layout(constraints: BoxConstraints(
            minSize: Size(constraints.minSize.width - padding.left - padding.right, constraints.minSize.height - padding.top - padding.bottom),
            maxSize: Size(constraints.maxSize.width - padding.left - padding.right, constraints.maxSize.height - padding.top - padding.bottom)
        ))
        bounds.size = Size(
            child.bounds.size.width + padding.left + padding.right,
            child.bounds.size.height + padding.top + padding.bottom
        )*/
    }

    /*override public func getContentSize() throws -> Size {
        let childContentSize = try child.getContentSize()
        return Size(childContentSize.width + padding.left + padding.right, childContentSize.height + padding.top + padding.bottom)
    }*/
}