import Foundation
import VisualAppBase
import WidgetGUI
import CustomGraphicsMath
import Dispatch

public class GameView: Widget {
    private var getDrawableState: () -> DrawableGameState
    
    public init(getDrawableState: @escaping () -> DrawableGameState) {
        self.getDrawableState = getDrawableState
    }

    override open func performLayout() {
        bounds.size = constraints!.maxSize
    }

    override open func renderContent() -> RenderObject? {
        return RenderObject.Custom(id: id) { [unowned self] renderer in
            let state = getDrawableState()

            try renderer.scale(DVec2(1, -1))
            try renderer.translate(DVec2(0, -globalBounds.size.height - globalBounds.min.y))
        
            let currentTimestamp = Date.timeIntervalSinceReferenceDate
            
            for i in 0..<state.blobs.count {
                let blob = state.blobs[i]

                blob.updateVertices(at: currentTimestamp)

                if blob.vertices.count > 0 {

                    try renderer.beginPath()
                    try renderer.moveTo(blob.vertices[0])

                    for vertex in blob.vertices[1...] {
                        try renderer.lineTo(vertex)
                    }
                    
                    try renderer.closePath()
                    if blob.consumed {
                        try renderer.fillColor(.Red)
                    } else {
                        try renderer.fillColor(.Green)
                    }
                    //try renderer.strokeColor(.Green)
                    //try renderer.strokeWidth(2)
                    //try renderer.stroke()
                    try renderer.fill()
                }
            }
        }
    }
}