import GfxMath

public class Theme: Style {
  public init(styles: [Style]) {
    super.init(StyleSelector(StyleSelectorPart(extendsParent: true)), [], styles)
  }
}

public class DefaultTheme: Theme {
  public init() {
    let primaryColor = Color(52, 122, 235, 255)

    super.init(styles: [
      Style(StyleSelector(StyleSelectorPart(type: Button.self)), Button.self) {
        ($0.padding, Insets(all: 16))
        ($0.background, primaryColor)

        Style(StyleSelector(StyleSelectorPart(extendsParent: true, pseudoClasses: ["hover"])), Button.self) {
          ($0.background, primaryColor.darkened(10))
        }

        Style(StyleSelector(StyleSelectorPart(extendsParent: false, opensScope: false, type: Text.self)), Text.self) {
          ($0.foreground, Color.white)
          ($0.fontSize, 24.0)
        }
      },
      Style(StyleSelector(StyleSelectorPart(type: TextInput.self)), TextInput.self) {
        ($0.padding, Insets(top: 16, right: 8, bottom: 16, left: 8))
        ($0.borderColor, primaryColor)
        ($0.borderWidth, BorderWidth(bottom: 1))
      }
    ])
  }
}