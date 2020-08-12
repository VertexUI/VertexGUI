import VisualAppBase
import CustomGraphicsMath
import WidgetGUI

public class PlayerStatsView: SingleChildWidget {
    public var blob: PlayerBlob {
        didSet {
            invalidateChild()
        }
    }
    
    public init(blob: PlayerBlob) {
        self.blob = blob
    }

    override open func buildChild() -> Widget {
        Background(Color(0, 0, 0, 200)) {
            Padding(all: 32) {
                // TODO: make Text init more convenient (less nesting of config objects)
                TextConfigProvider(fontSize: 20, color: .White) {
                    Column(spacing: 32) {
                        Text(
                            "Stats",
                            config: Text.PartialConfig(
                                fontConfig: PartialFontConfig(size: 24, weight: .Bold), color: .White))

                        Text("Mass: \(blob.mass)")

                        Text("Acceleration: \(blob.acceleration)")

                        Text("Speed: \(blob.speed)")


                    }
                }
            }
        }
    }
}