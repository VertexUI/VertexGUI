import VisualAppBase
import Path
import Foundation

public let defaultFontFamily = FontFamily(
    name: "Roboto",
    faces: [
        FontFace(path: Bundle.module.path(forResource: "Roboto-Regular", ofType: "ttf")!, weight: .regular, style: .Normal),
        FontFace(path: Bundle.module.path(forResource: "Roboto-Bold", ofType: "ttf")!, weight: .bold, style: .Normal),
    ]
)