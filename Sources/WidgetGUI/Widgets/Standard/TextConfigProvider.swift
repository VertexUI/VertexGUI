import VisualAppBase

public class TextConfigProvider: SingleChildWidget {
    public var config: Text.PartialConfig
    private var inputChild: Widget

    public init(config: Text.PartialConfig, @WidgetBuilder child inputChild: () -> Widget) {
        self.config = config
        self.inputChild = inputChild()
        super.init()
    }

    override open func buildChild() -> Widget {
        inputChild
    }
}