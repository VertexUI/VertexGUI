import GfxMath
import VisualAppBase

public class Space: Widget {
    public var preferredSize: DSize2 {
        didSet {
            invalidateLayout()
        }
    }

    public init(_ preferredSize: DSize2) {
        self.preferredSize = preferredSize
        super.init()
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
        constraints.constrain(preferredSize)
    }

    deinit {
        print("DEINIT SPACE")
    }
}
