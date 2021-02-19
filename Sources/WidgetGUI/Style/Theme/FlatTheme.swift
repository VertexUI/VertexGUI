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
      }
    }
  }
}