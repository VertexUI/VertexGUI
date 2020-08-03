import CustomGraphicsMath

public class Center: SingleChildWidget {
    private var inputChildBuilder: () -> Widget
    
    public init(@WidgetBuilder child inputChildBuilder: @escaping () -> Widget) {
        self.inputChildBuilder = inputChildBuilder
        super.init()
    }

    override open func buildChild() -> Widget {
        inputChildBuilder()
    }

    override open func performLayout() {
        child.constraints = BoxConstraints(minSize: DSize2.zero, maxSize: constraints!.maxSize)
        child.layout()
        bounds.size = constraints!.constrain(child.bounds.size)
        child.bounds.min = DVec2(bounds.size - child.bounds.size) / 2
    }
}
