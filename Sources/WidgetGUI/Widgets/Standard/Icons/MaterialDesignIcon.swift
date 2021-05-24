import GfxMath
import Foundation
import Drawing

// TODO: actually these are MaterialDESIGNIcons (not from google) --> use the google ones
public class MaterialDesignIcon: ContentfulWidget {
  private let identifier: Identifier

  public init(_ identifier: Identifier) {
    self.identifier = identifier
    super.init()
  }

  @DirectContentBuilder override public var content: DirectContent {
    Text(String(Unicode.Scalar(identifier.code)!))/*.with(styleProperties: {
      //(\.$fontFamily, MaterialDesignIcon.materialFontFamily)
    })*/
  }
}