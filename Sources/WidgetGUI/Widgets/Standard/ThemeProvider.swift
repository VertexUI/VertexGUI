/// TODO: implement
public class ThemeProvider: SingleChildWidget {
    private var inputChild: Widget
    
    public init(@WidgetBuilder child inputChild: () -> Widget) {
        self.inputChild = inputChild()
    }

    override open func buildChild() -> Widget {
        inputChild
    }
}