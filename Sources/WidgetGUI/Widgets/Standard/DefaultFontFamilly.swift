import VisualAppBase
import Path
import Foundation

public let defaultFontFamily = FontFamily(
    name: "Roboto",
    faces: [
        FontFace(path: Bundle.module.path(forResource: "Roboto-Regular", ofType: "ttf")!, weight: .Regular, style: .Normal),
        FontFace(path: Bundle.module.path(forResource: "Roboto-Bold", ofType: "ttf")!, weight: .Bold, style: .Normal),
    ]
)