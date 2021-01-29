import GfxMath
import VisualAppBase

public class Clip: SingleChildWidget {

    private let insets: Insets    

    private let childBuilder: () -> Widget

    public init(_ insets: Insets = Insets(0), @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.insets = insets 

        self.childBuilder = childBuilder
    }

    override public func buildChild() -> Widget {

        childBuilder()
    }

    override public func renderContent() -> RenderObject? {

        RenderObject.Clip(DRect(

            min: globalBounds.min + DVec2(insets.left, insets.top),

            max: globalBounds.max - DVec2(insets.right, insets.bottom))) {

            child.render(reason: .renderContentOfParent(self))
        }
    }
}