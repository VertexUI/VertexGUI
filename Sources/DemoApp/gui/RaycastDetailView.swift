import WidgetGUI
import CustomGraphicsMath

public class RaycastDetailView: SingleChildWidget {
    private var raycast: TwoDRaycast
    
    public init(raycast: TwoDRaycast) {
        self.raycast = raycast    
    }

    override public func buildChild() -> Widget {
        Column {
            Text("Raycast")
            
            Text("From \(self.vectorText(raycast.start))")
            Text("To \(self.vectorText(raycast.end))")

            raycast.results.compactMap {
                switch $0 {
                case .Hit(let tileIndex, let edge):
                    return Text("Hit: \(edge.rawValue)")
                default:
                    break
                }
                return nil
            }
        }
    }

    private func vectorText(_ vector: DVec2) -> String {
        "(\(vector.elements.map({ String(format: "%.3f", $0 ) }).joined(separator: " | ")))"
    }
}