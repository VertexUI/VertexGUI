import GfxMath
import VisualAppBase

public class FlatTheme {
  public let primaryColor: Color
  public let textColorOnPrimary: Color
  public let secondaryColor: Color
  public let textColorOnSecondary: Color
  public let backgroundColor: Color
  public let textColorOnBackground: Color

  public init(primaryColor: Color, secondaryColor: Color, backgroundColor: Color) {
    self.primaryColor = primaryColor
    self.secondaryColor = secondaryColor
    self.backgroundColor = backgroundColor
    if primaryColor.l > 0.5 {
      textColorOnPrimary = .black
    } else {
      textColorOnPrimary = .white
    }
    if secondaryColor.l > 0.5 {
      textColorOnSecondary = .black
    } else {
      textColorOnSecondary = .white
    }
    if backgroundColor.l > 0.5 {
      textColorOnBackground = .black
    } else {
      textColorOnBackground = .white
    }
  }

  public var experimentalStyles: Experimental.Style {
    Experimental.Style("&") {
      (\.$foreground, textColorOnBackground)
    } nested: {

      Experimental.Style([StyleSelectorPart(type: Button.self)]) {
        (\.$background, primaryColor)
        (\.$padding, Insets(all: 16))
        (\.$foreground, textColorOnPrimary)
      } nested: {
        Experimental.Style([StyleSelectorPart(extendsParent: true, pseudoClasses: ["hover"])]) {
          (\.$background, primaryColor.darkened(30))
        }
      }

      Experimental.Style([StyleSelectorPart(type: TextInput.self)], TextInput.self) {
        (\.$caretColor, primaryColor)
      }

      Experimental.Style([StyleSelectorPart(type: Widget.ScrollBar.self)], Widget.ScrollBar.self) {
        (\.$background, .transparent)
        (\.$foreground, primaryColor)
        (\.$xBarHeight, 20)
        (\.$yBarWidth, 20)
      } nested: {

        Experimental.Style("&:hover") {
          (\.$foreground, primaryColor.darkened(30))
        }
      }
    }
  }
}