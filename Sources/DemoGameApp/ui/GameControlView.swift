import VisualAppBase
import CustomGraphicsMath
import WidgetGUI

public class GameControlView: SingleChildWidget {
    public var blob: Observable<PlayerBlob>
    
    public init(blob: Observable<PlayerBlob>) {
        self.blob = blob
        super.init()
    }

    override open func buildChild() -> Widget {

        Background(fill: Color(0, 0, 0, 200)) { [unowned self] in

            Padding(top: 32, right: 32, bottom: 48, left: 32) {
                
                TextConfigProvider(color: .White) {

                    Column {

                        TextConfigProvider(fontSize: 20, wrap: true) {

                            ObservingBuilder(AnyObservable(blob)) {

                                Column(spacing: 32) {
                                    
                                    Text("Stats", fontSize: 48, fontWeight: .Bold, color: .White)

                                    Text("Id: \(blob.value.id)")

                                    Text("Position: x: \(Int(blob.value.position.x)) y: \(Int(blob.value.position.y))")

                                    Text("Mass: \(blob.value.mass)")

                                    Text("Radius: \(Int(blob.value.radius))")
                                    
                                    Text("Max Acceleration: \(Int(blob.value.maxAcceleration))")
                                    
                                    Text("Acceleration: x: \(Int(blob.value.acceleration.x)) y: \(Int(blob.value.acceleration.y)) m: \(Int(blob.value.acceleration.magnitude))")

                                    Text("Speed: x: \(Int(blob.value.speed.x)) y: \(Int(blob.value.speed.y)) m: \(Int(blob.value.speed.magnitude))")

                                    Text("Speed limit: \(String(format: "%.3f", blob.value.speedLimit))")
                                    
                                    Text("Size: x: \(Int(blob.value.bounds.size.x)) y: \(Int(blob.value.bounds.size.y))")
                                    
                                    Text("Vision Distance: \(String(format: "%.3f", blob.value.visionDistance))")
                                }
                            }
                        }

                        GameRulesetEditorView()
                    }
                }
            }
        }
    }
}