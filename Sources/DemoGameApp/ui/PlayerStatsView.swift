import VisualAppBase
import CustomGraphicsMath
import WidgetGUI

public class PlayerStatsView: SingleChildWidget {
    public var blob: Observable<PlayerBlob>
    
    public init(blob: Observable<PlayerBlob>) {
        self.blob = blob
        super.init()
        _ = onDestroy(blob.onChanged { [unowned self] _ in
            invalidateChild()
        })
    }

    override open func buildChild() -> Widget {
        Background(
            Color(0, 0, 0, 200), 
            shape: .RoundedRectangle(CornerRadii(all: 16))) {
                Padding(top: 32, right: 32, bottom: 48, left: 32) {
                    TextConfigProvider(fontSize: 20, color: .White, wrap: true) {
                        Column(spacing: 32) {
                            Text(
                                "Stats",
                                config: Text.PartialConfig(
                                    fontConfig: PartialFontConfig(size: 24, weight: .Bold), color: .White))

                            Text("Mass: \(blob.value.mass)")

                            Text("Acceleration: \(blob.value.acceleration)")

                            Text("Speed: \(blob.value.speed)")


                        }
                    }
                }
        }
    }
}