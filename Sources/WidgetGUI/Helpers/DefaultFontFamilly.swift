import VisualAppBase
import Foundation
import Drawing

public let defaultFontFamily = FontFamily(
    name: "Roboto",
    faces: [
        FontFace(path: Bundle.module.path(forResource: "Roboto-Regular", ofType: "ttf")!, weight: .regular, style: .normal),
        FontFace(path: Bundle.module.path(forResource: "Roboto-Bold", ofType: "ttf")!, weight: .bold, style: .normal),
    ]
)