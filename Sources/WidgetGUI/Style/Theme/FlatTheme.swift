import GfxMath

public class FlatTheme: Theme {
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
      (\.$foreground, textColorOnBackground)
    } nested: {

      Style([StyleSelectorPart(type: Button.self)]) {
        (\.$background, primaryColor)
        (\.$padding, Insets(all: 16))
        (\.$foreground, textColorOnPrimary)
      } nested: {
        Style([StyleSelectorPart(extendsParent: true, pseudoClasses: ["hover"])]) {
          (\.$background, primaryColor.darkened(30))
        }
      }

      Style([StyleSelectorPart(type: TextInput.self)], TextInput.self) {
        (\.$caretColor, primaryColor)
      }

      Style([StyleSelectorPart(type: Widget.ScrollBar.self)], Widget.ScrollBar.self) {
        (\.$background, .transparent)
        (\.$foreground, primaryColor)
        (\.$xBarHeight, 20)
        (\.$yBarWidth, 20)
      } nested: {

        Style("&:hover") {
          (\.$foreground, primaryColor.darkened(30))
        }
      }

      Style("Select") {
        (\.$background, .yellow)
        (\.$debugLayout, true)
      } nested: {
        Style(".value-field") {
          (\.$borderWidth, Insets(all: 1))
          (\.$borderColor, .yellow)
        }

        Style(".options-field") {
          (\.$borderWidth, Insets(all: 1))
          (\.$borderColor, .yellow)
        }

        Style(".option") {
          (\.$padding, Insets(all: 8))
        } nested: {
          Style("&.selected") {
            (\.$background, primaryColor)
          }
        }
      }
    }
  }
}