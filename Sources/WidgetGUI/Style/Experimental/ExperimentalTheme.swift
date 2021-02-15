import GfxMath

extension Experimental {
  public class Theme: Experimental.Style {
    public init(styles: [Experimental.Style]) {
      super.init(StyleSelector(StyleSelectorPart(extendsParent: true)), [], styles)
    }
  }

  public class DefaultTheme: Experimental.Theme {
    public init() {
      let primaryColor = Color(52, 122, 235, 255)

      super.init(styles: [
        Experimental.Style(StyleSelector(StyleSelectorPart(type: Experimental.Button.self)), Experimental.Button.self) {
          ($0.padding, Insets(all: 16))
          ($0.background, primaryColor)

          Experimental.Style(StyleSelector(StyleSelectorPart(extendsParent: true, pseudoClasses: ["hover"])), Experimental.Button.self) {
            ($0.background, primaryColor.darkened(10))
          }

          Experimental.Style(StyleSelector(StyleSelectorPart(extendsParent: false, opensScope: false, type: Experimental.Text.self)), Experimental.Text.self) {
            ($0.foreground, Color.white)
            ($0.fontSize, 24.0)
          }
        },
        Experimental.Style(StyleSelector(StyleSelectorPart(type: Experimental.TextInput.self)), Experimental.TextInput.self) {
          ($0.padding, Insets(top: 16, right: 8, bottom: 16, left: 8))
          ($0.borderColor, primaryColor)
          ($0.borderWidth, BorderWidth(bottom: 1))
        }
      ])
    }
  }
}