/*
public class ClipArea: Widget {
    public var child: Widget

    public init(child: Widget, sizeConfig: SizeConfig) {
        self.child = child
        super.init(sizeConfig: sizeConfig, children: [child])
    }

    override public func getContentSize() throws -> Size {
        return try child.getContentSize()
    }

    override public func layout() {
        child.bounds = bounds
        try child.layout()
    }

    override public func render(renderer: Renderer) throws {
        try renderer.clipArea(bounds: bounds)
        try child.render(renderer: renderer)
        try renderer.releaseClipArea()
    }
}*/