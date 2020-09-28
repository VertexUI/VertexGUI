import CustomGraphicsMath
import VisualAppBase

public class Space: Widget {

    private let preferredSize: DSize2

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
