import CustomGraphicsMath
import VisualAppBase

public class Space: Widget {

    public var preferredSize: DSize2 {

        didSet {

            invalidateBoxConfig()

            invalidateLayout()
        }
    }

    public init(_ preferredSize: DSize2) {
        
        self.preferredSize = preferredSize
    }

    override public func getBoxConfig() -> BoxConfig {

        BoxConfig(preferredSize: preferredSize)
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        constraints.constrain(preferredSize)
    }

    override public func renderContent() -> RenderObject? {

        nil
    }
}
