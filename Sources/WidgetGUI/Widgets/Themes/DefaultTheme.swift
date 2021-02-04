import GfxMath
import VisualAppBase

public class DefaultTheme: Theme {
  public enum Mode {
    case Light, Dark
  }

  public var configs: [PartialConfigMarkerProtocol]
  public var mode: Mode
  public var primaryColor: Color
  public var backgroundColor: Color

  public init(mode: Mode, primaryColor: Color, backgroundColor: Color) {
    self.mode = mode
    self.primaryColor = primaryColor
    self.backgroundColor = backgroundColor

    self.configs = [
      Background.PartialConfig {
        $0.fill = backgroundColor
        $0.shape = .Rectangle
      },

      Text.PartialConfig {
        $0.color = mode == .Light ? Color.black : Color.white
      },

      TextField.PartialConfig {
        $0.backgroundConfig {
          $0.fill = Color(40, 40, 50, 255)
          $0.shape = .Rectangle  // .RoundedRectangle(CornerRadii(all: 24))
        }

        $0.borderColor = primaryColor
      },

      TextInput.PartialConfig {
        $0.caretColor = primaryColor.lightened(50)
      }
    ]
  }
}
