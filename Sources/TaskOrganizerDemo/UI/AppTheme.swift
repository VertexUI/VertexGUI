import WidgetGUI
import GfxMath

// TODO: maybe add AppTheme.defaultStyles -> add globally
public enum AppTheme {
    public static let primaryColor = Color(90, 232, 183, 255)
    public static let backgroundColor = Color(10, 24, 36, 255)
}

let appTheme = DefaultTheme(

    mode: .Dark,

    primaryColor: Color(90, 232, 183, 255),

    backgroundColor: Color(10, 24, 36, 255))