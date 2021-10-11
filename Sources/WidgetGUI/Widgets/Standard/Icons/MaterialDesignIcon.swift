import GfxMath
import Foundation
import Drawing

// TODO: actually these are MaterialDESIGNIcons (not from google) --> use the google ones
public class MaterialDesignIcon: ComposedWidget {
  private let identifier: Identifier

  public init(_ identifier: Identifier) {
    self.identifier = identifier
    super.init()
  }

  @Compose override public var content: ComposedContent {
    Text(String(Unicode.Scalar(identifier.code)!))/*.with(styleProperties: {
      //(\.$fontFamily, MaterialDesignIcon.materialFontFamily)
    })*/
  }
}