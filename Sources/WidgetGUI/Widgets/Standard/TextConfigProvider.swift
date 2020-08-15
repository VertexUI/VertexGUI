import VisualAppBase
import CustomGraphicsMath

public class TextConfigProvider: ConfigProvider {
    public init(config: Text.PartialConfig, @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        super.init(configs: [config], child: childBuilder)
    }

    public convenience init(
        fontFamily: FontFamily? = nil,
        fontSize: Double? = nil,
        fontWeight: FontWeight? = nil,
        fontStyle: FontStyle? = nil,
        transform: TextTransform? = nil,
        color: Color? = nil,
        wrap: Bool? = nil,
        @WidgetBuilder child childBuilder: @escaping () -> Widget
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
}