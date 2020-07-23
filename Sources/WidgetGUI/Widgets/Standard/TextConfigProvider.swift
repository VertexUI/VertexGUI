import VisualAppBase

public class TextConfigProvider: SingleChildWidget {
    public var textConfig: TextConfig

    public init(child: Widget, config textConfig: TextConfig) {
        self.textConfig = textConfig
        super.init(child: child)
    }

    override open func layout(fromChild: Bool = false) throws {
        child.constraints = constraints
        try child.layout()
        bounds = child.bounds
    }
}