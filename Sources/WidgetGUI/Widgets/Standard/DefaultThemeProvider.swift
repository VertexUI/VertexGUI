import VisualAppBase
import CustomGraphicsMath

public class DefaultThemeProvider: ConfigProvider {
    public enum Mode {
        case Light, Dark
    }
    
    public var mode: Mode

    public var primaryColor: Color

    public init(mode: Mode, primaryColor: Color, @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        let backgroundColor: Color = mode == .Light ? Color.White : Color.Grey

        self.mode = mode
        self.primaryColor = primaryColor

        super.init(configs: [
            TextField.PartialConfig(
                backgroundConfig: Background.Config(
                    fill: backgroundColor,
                    shape: Background.Shape.RoundedRectangle(CornerRadii(all: 24)))
            ),
            TextInput.PartialConfig(
                caretColor: primaryColor
            )
        ], child: childBuilder)
    }
}