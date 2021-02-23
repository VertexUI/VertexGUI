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

  public var styles: Style {
    Style("&") {
      ($0.foreground, textColorOnBackground)

      Style(StyleSelector(StyleSelectorPart(type: Button.self))) {
        ($0.background, primaryColor)
        ($0.padding, Insets(all: 16))
        ($0.foreground, textColorOnPrimary)
        ($0.fontWeight, FontWeight.bold)

        Style(StyleSelector(StyleSelectorPart(extendsParent: true, pseudoClasses: ["hover"]))) {
          ($0.background, primaryColor.darkened(30))
        }

        Style(StyleSelector(StyleSelectorPart(extendsParent: false, opensScope: false, type: Text.self))) {
          ($0.fontSize, 16)
        }
      }
      
      Style(StyleSelector(StyleSelectorPart(type: TextInput.self)), TextInput.self) {
        ($0.background, Color.transparent)
        ($0.foreground, textColorOnBackground)
        ($0.padding, Insets(top: 16, right: 8, bottom: 16, left: 8))
        ($0.borderColor, primaryColor)
        ($0.borderWidth, Insets(bottom: 1))
        ($0.caretColor, primaryColor)
      }

      Style(StyleSelector(StyleSelectorPart(type: Widget.ScrollBar.self))) {
        ($0.background, Color.transparent)
        ($0.foreground, primaryColor)

        Style("&:hover") {
          ($0.foreground, primaryColor.darkened(30))
        }
      }
    }
  }
}