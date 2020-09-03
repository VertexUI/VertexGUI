import CustomGraphicsMath
import VisualAppBase

public class Space: Widget {

    private let size: DSize2

    public init(_ size: DSize2) {
        
        self.size = size
    }

    override public func getBoxConfig() -> BoxConfig {

        BoxConfig(preferredSize: size)
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        constraints.constrain(size)
    }

    override public func renderContent() -> RenderObject? {

        nil
    }
}