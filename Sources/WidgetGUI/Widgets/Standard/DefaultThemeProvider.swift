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
            ),
            Button.PartialConfig(
                normalStyle: Button.StateStyle(background: primaryColor),
                hoverStyle: Button.StateStyle(background: primaryColor.adjusted(alpha: 120)),
                activeStyle: Button.StateStyle(background: primaryColor.adjusted(alpha: 50))
            )
        ], child: childBuilder)
    }
}