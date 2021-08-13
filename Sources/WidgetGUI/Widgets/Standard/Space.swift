import GfxMath

public class Space: Widget {
    public var preferredSize: DSize2 {
        didSet {
            invalidateLayout()
        }
    }

    public init(_ preferredSize: DSize2) {
        self.preferredSize = preferredSize
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
        constraints.constrain(preferredSize)
    }
}
