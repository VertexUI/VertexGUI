import VisualAppBase

public class TextConfigProvider: SingleChildWidget {
    public var textConfig: TextConfig
    private var inputChild: Widget

    public init(config textConfig: TextConfig, child inputChild: Widget) {
        self.textConfig = textConfig
        self.inputChild = inputChild
        super.init()
    }

    override open func buildChild() -> Widget {
        return inputChild
    }

    override open func layout(fromChild: Bool = false) throws {
        child.constraints = constraints
        try child.layout()
        bounds = child.bounds
    }
}