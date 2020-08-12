import VisualAppBase
import CustomGraphicsMath

public class TextConfigProvider: SingleChildWidget {
    public var config: Text.PartialConfig
    private var inputChild: Widget

    public init(config: Text.PartialConfig, @WidgetBuilder child inputChild: () -> Widget) {
        self.config = config
        self.inputChild = inputChild()
        super.init()
    }

    public convenience init(
        fontFamily: FontFamily? = nil,
        fontSize: Double? = nil,
        fontWeight: FontWeight? = nil,
        fontStyle: FontStyle? = nil,
        transform: TextTransform? = nil,
        color: Color? = nil,
        wrap: Bool? = nil,
        @WidgetBuilder child childBuilder: () -> Widget
        ) {
            self.init(config: Text.PartialConfig(
                fontConfig: PartialFontConfig(
                    family: fontFamily,
                    size: fontSize,
                    weight: fontWeight,
                    style: fontStyle
                ),
                transform: transform,
                color: color,
                wrap: wrap
            ), child: childBuilder)
    }

    override open func buildChild() -> Widget {
        inputChild
    }
}