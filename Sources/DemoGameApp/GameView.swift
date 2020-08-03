import Foundation
import VisualAppBase
import WidgetGUI
import CustomGraphicsMath

public class GameView: Widget {
    private var state: GameState
    
    public init(state: GameState) {
        self.state = state
    }

    override open func performLayout() {
        bounds.size = DSize2(500, 500)
    }

    override open func renderContent() -> RenderObject? {
        return RenderObject.Custom(id: id) { [unowned self] renderer in
            try renderer.scale(DVec2(1, -1))
            try renderer.translate(DVec2(0, -globalBounds.size.height - globalBounds.topLeft.y))
        
            let currentTimestamp = Date.timeIntervalSinceReferenceDate
            
            for blob in state.blobs {

                let vertices = blob.generateVertices(at: currentTimestamp)
                
                if vertices.count > 0 {

                    try renderer.beginPath()
                    try renderer.moveTo(vertices[0])

                    for vertex in vertices[1...] {
                        try renderer.lineTo(vertex)
                    }
                    
                    try renderer.closePath()
                    try renderer.fillColor(.Red)
                    //try renderer.strokeColor(.Green)
                    //try renderer.strokeWidth(2)
                    //try renderer.stroke()
                    try renderer.fill()
                }
            }
        }
    }
}