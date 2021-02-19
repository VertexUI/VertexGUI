import GfxMath
import Foundation
import VisualAppBase

// TODO: actually these are MaterialDESIGNIcons (not from google) --> use the google ones
public class MaterialDesignIcon: ComposedWidget {
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

  override public func performBuild() {
    rootChild = Text(styleProperties: {
      ($0.fontFamily, MaterialDesignIcon.materialFontFamily)
    }, String(Unicode.Scalar(identifier.code)!))
  }
}