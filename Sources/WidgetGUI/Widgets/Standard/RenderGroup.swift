import VisualAppBase

public class RenderGroup: SingleChildWidget {

    private let childBuilder: () -> Widget

    public init(@WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.childBuilder = childBuilder
    }

    override public func buildChild() -> Widget {

        childBuilder()
    }

    override public func renderContent() -> RenderObject? {

        CacheSplitRenderObject {

            super.renderContent()
        }
    }
}