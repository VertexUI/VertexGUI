import Foundation
import VisualAppBase
import CustomGraphicsMath

public class GameRenderer {
    private let getRenderData: () -> (drawableState: DrawableGameState, perspective: GamePerspective)
    
    public init(getRenderData: @escaping () -> (drawableState: DrawableGameState, perspective: GamePerspective)) {
        self.getRenderData = getRenderData
    }

    public func render(in screenArea: DRect, with renderer: Renderer) throws {
        let (state, perspective) = getRenderData()
        //let centerPosition = perspective.visibleArea

        try renderer.scale(DVec2(1, -1))
        try renderer.translate(DVec2(0, -screenArea.size.height - screenArea.min.y))
    
        let currentTimestamp = Date.timeIntervalSinceReferenceDate
        
        for blob in state.blobs.values {
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