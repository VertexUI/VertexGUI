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

    override open func performLayout(constraints: BoxConstraints) -> DSize2 {
        
        child.layout(constraints: BoxConstraints(minSize: DSize2.zero, maxSize: constraints.maxSize))
        
        child.bounds.min = DVec2(bounds.size - child.bounds.size) / 2

        return constraints.constrain(child.bounds.size)
    }
}
