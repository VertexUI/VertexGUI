import GfxMath

public class FlatTheme {
  public let primaryColor: Color
  public let textColorOnPrimary: Color = Color.white
  public let secondaryColor: Color
  public let textColorOnSecondary: Color = Color.white
  public let backgroundColor: Color
  public let textColorOnBackground: Color = Color.white

  public init(primaryColor: Color, secondaryColor: Color, backgroundColor: Color) {
    self.primaryColor = primaryColor
    self.secondaryColor = secondaryColor
    self.backgroundColor = backgroundColor
  }

  public var styles: Style {
    Style("&") {

      Style(StyleSelector(StyleSelectorPart(type: Button.self))) {
        ($0.background, primaryColor)
        ($0.padding, Insets(all: 16))
        ($0.foreground, textColorOnPrimary)

        Style(StyleSelector(StyleSelectorPart(extendsParent: true, pseudoClasses: ["hover"]))) {
          ($0.background, primaryColor.darkened(10))
        }

        Style(StyleSelector(StyleSelectorPart(extendsParent: false, opensScope: false, type: Text.self))) {
          ($0.foreground, Color.white)
          ($0.fontSize, 24.0)
        }
      }
      
      Style(StyleSelector(StyleSelectorPart(type: TextInput.self)), TextInput.self) {
        ($0.background, Color.transparent)
        ($0.foreground, textColorOnBackground)
        ($0.padding, Insets(top: 16, right: 8, bottom: 16, left: 8))
        ($0.borderColor, primaryColor)
        ($0.borderWidth, Insets(bottom: 1))
      }
    }
  }
}