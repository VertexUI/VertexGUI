import VisualAppBase
import Path

public let defaultFontFamily = FontFamily(
    name: "Roboto",
    faces: [
        FontFace(path: (Path.cwd/"Sources/WidgetGUI/assets/Roboto-Regular.ttf").string, weight: .Regular, style: .Normal),
        FontFace(path: (Path.cwd/"Sources/WidgetGUI/assets/Roboto-Bold.ttf").string, weight: .Bold, style: .Normal),
    ]
)