import CustomGraphicsMath

public class Center: SingleChildWidget {
    private var inputChild: Widget
    
    public init(@WidgetBuilder child: () -> Widget) {
        self.inputChild = child()
        super.init()
    }

    override open func buildChild() -> Widget {
        inputChild
    }

    override open func layout() {
        child.constraints = BoxConstraints(minSize: DSize2.zero, maxSize: constraints!.maxSize)
        child.layout()
        bounds.size = constraints!.constrain(child.bounds.size)
        child.bounds.topLeft = DVec2(bounds.size - child.bounds.size) / 2
    }
}