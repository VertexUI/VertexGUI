import VisualAppBase
import CustomGraphicsMath

public class DefaultTheme: Theme {
    public enum Mode {
        case Light, Dark
    }

    public var configs: [PartialConfigMarker]
    
    public var mode: Mode

    public var primaryColor: Color

    public init(mode: Mode, primaryColor: Color) {
        let backgroundColor: Color = mode == .Light ? Color.White : Color.Grey

        self.mode = mode
        self.primaryColor = primaryColor

        self.configs = [
            TextField.PartialConfig {
                $0.backgroundConfig {
                    $0.fill = Color(40, 40, 50, 255)
                    $0.shape = .RoundedRectangle(CornerRadii(all: 24))
                }
            },
            TextInput.PartialConfig {
                $0.caretColor = primaryColor.lightened(50)
            },
            Button.PartialConfig {
                $0.normalStyle {
                    $0.backgroundConfig {
                        $0.fill = primaryColor
                        $0.shape = .RoundedRectangle(CornerRadii(all: 8))
                    }
                    $0.textConfig {
                        $0.color = Color(255, 255, 255, 255)
                    }
                }
                    
                $0.hoverStyle {
                    $0.backgroundConfig {
                        $0.fill = primaryColor.adjusted(alpha: 140)
                        $0.shape = .Rectangle
                    }
                    $0.textConfig {
                        $0.color = .White
                    }
                }

                $0.activeStyle {
                    $0.backgroundConfig {
                        $0.fill = primaryColor.adjusted(alpha: 60)
                        $0.shape = .Rectangle
                    }
                    $0.textConfig {
                        $0.color = .White
                    }
                }
            }
        ]
    }
}