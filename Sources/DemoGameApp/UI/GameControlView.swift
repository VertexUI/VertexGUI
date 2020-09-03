import VisualAppBase
import CustomGraphicsMath
import WidgetGUI

public class GameControlView: SingleChildWidget {
    override open func buildChild() -> Widget {

        Background(fill: Color(20, 20, 30, 255)) { [unowned self] in

            Padding(top: 32, right: 32, bottom: 48, left: 32) {
                
                TextConfigProvider(color: .White) {

                    Column {

                        /*TextConfigProvider(fontSize: 20, wrap: true) {

                            ObservingBuilder(AnyObservable(player)) {

                                Column(spacing: 32) {
                                    
                                    Text("Stats", fontSize: 48, fontWeight: .Bold, color: .White)

                                    Text("Id: \(player.state.player.value.id)")

                                    Text("Position: x: \(Int(player.state.player.value.position.x)) y: \(Int(player.state.player.value.position.y))")

                                    Text("Mass: \(player.state.player.value.mass)")

                                    Text("Radius: \(Int(player.state.player.value.radius))")
                                    
                                    Text("Max Acceleration: \(Int(player.state.player.value.maxAcceleration))")
                                    
                                    Text("Acceleration: x: \(Int(player.state.player.value.acceleration.x)) y: \(Int(player.state.player.value.acceleration.y)) m: \(Int(player.state.player.value.acceleration.magnitude))")

                                    Text("Speed: x: \(Int(player.state.player.value.speed.x)) y: \(Int(player.state.player.value.speed.y)) m: \(Int(player.state.player.value.speed.magnitude))")

                                    Text("Speed limit: \(String(format: "%.3f", player.state.player.value.speedLimit))")
                                    
                                    Text("Size: x: \(Int(player.state.player.value.bounds.size.x)) y: \(Int(player.state.player.value.bounds.size.y))")
                                    
                                    Text("Vision Distance: \(String(format: "%.3f", player.state.player.value.visionDistance))")
                                }
                            }
                        }*/

                        Expandable {
                            GameRulesetEditorView()
                        }
                    }
                }
            }
        }
    }
}