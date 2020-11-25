import GfxMath
import Foundation
import VisualAppBase

// TODO: actually these are MaterialDESIGNIcons (not from google) --> use the google ones
public class MaterialIcon: SingleChildWidget {
  private let identifier: Identifier
  private let color: Color
  private static let materialFontFamily = FontFamily(
    name: "Material Icons",
    faces: [
      FontFace(
        path: Bundle.module.path(forResource: "materialdesignicons-webfont", ofType: "ttf")!,
        weight: .Regular,
        style: .Normal
      )
    ])

  public init(_ identifier: Identifier, color: Color = .Black) {
    self.identifier = identifier
    self.color = color
  }

  override public func buildChild() -> Widget {
    Text(
      String(Unicode.Scalar(identifier.code)!), fontFamily: MaterialIcon.materialFontFamily,
      color: color)
  }
}
