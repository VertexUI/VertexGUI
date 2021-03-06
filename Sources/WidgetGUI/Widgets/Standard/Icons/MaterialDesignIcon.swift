import GfxMath
import Foundation
import VisualAppBase

// TODO: actually these are MaterialDESIGNIcons (not from google) --> use the google ones
public class MaterialDesignIcon: ContentfulWidget {
  private let identifier: Identifier

  private static let materialFontFamily = FontFamily(
    name: "Material Icons",
    faces: [
      FontFace(
        path: Bundle.module.path(forResource: "materialdesignicons-webfont", ofType: "ttf")!,
        weight: .regular,
        style: .normal
      )
    ])

  public init(_ identifier: Identifier) {
    self.identifier = identifier
    super.init()
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Text(String(Unicode.Scalar(identifier.code)!)).experimentalWith(styleProperties: {
      (\.$fontFamily, MaterialDesignIcon.materialFontFamily)
    })
  }
}