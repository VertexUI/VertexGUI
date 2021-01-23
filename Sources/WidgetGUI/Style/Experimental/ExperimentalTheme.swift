import GfxMath

extension Experimental {
  public class Theme: Experimental.Style {
    public init(styles: [Experimental.Style]) {
      super.init("", [], styles)
    }
  }

  public class DefaultTheme: Experimental.Theme {
    public init() {
      super.init(styles: [
        Experimental.Style(StyleSelector(StyleSelectorPart(type: Experimental.Button.self))) {
          (Experimental.Button.StyleKeys.padding, Insets(all: 16))
          (Experimental.Button.StyleKeys.backgroundFill, Color.red)

          Experimental.Style(StyleSelector(StyleSelectorPart(extendsParent: false, opensScope: false, type: Experimental.Text.self))) {
            (Experimental.Text.StyleKeys.fontSize, 48.0)
          }
        }
      ])
    }
  }
}