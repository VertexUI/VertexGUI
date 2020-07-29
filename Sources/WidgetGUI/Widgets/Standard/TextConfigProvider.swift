import VisualAppBase

public class TextConfigProvider: SingleChildWidget {
    public var textConfig: TextConfig
    private var inputChild: Widget

    public init(config textConfig: TextConfig, @WidgetBuilder child inputChild: () -> Widget) {
        self.textConfig = textConfig
        self.inputChild = inputChild()
        super.init()
    }

    override open func buildChild() -> Widget {
        inputChild
    }
}