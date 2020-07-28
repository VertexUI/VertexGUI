import WidgetGUI

public class RaycastDetailView: SingleChildWidget {
    private var raycast: TwoDRaycast
    
    public init(raycast: TwoDRaycast) {
        self.raycast = raycast    
    }

    override public func buildChild() -> Widget {
        Column {
            Text("Raycast \(raycast.start) to \(raycast.end)")
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
}