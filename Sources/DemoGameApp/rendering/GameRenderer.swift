import Foundation
import VisualAppBase
import CustomGraphicsMath

public class GameRenderer {
    private let state: DrawableGameState
    
    public init(drawableState state: DrawableGameState) {
        self.state = state
    }

    public func render(in screenArea: DRect, with renderer: Renderer) throws {
        let gameScreenFitScale: Double 
        if screenArea.size.height > screenArea.size.width {
            gameScreenFitScale = screenArea.size.height / state.perspective.visibleArea.size.height
        } else {
            gameScreenFitScale = screenArea.size.width / state.perspective.visibleArea.size.width
        }

        try renderer.translate(screenArea.min)
        try renderer.translate(DVec2(screenArea.size / 2))
        try renderer.scale(DVec2(gameScreenFitScale, gameScreenFitScale))
        try renderer.scale(DVec2(1, -1))
    
        for blob in state.blobs.values {
            let paddedVisibleArea = DRect(
                min: state.perspective.visibleArea.min - DVec2(blob.radius, blob.radius),
                max: state.perspective.visibleArea.max - DVec2(blob.radius, blob.radius))
            
            if !paddedVisibleArea.contains(point: blob.position) {
                continue
            }

            if blob.vertices.count > 0 {

                try renderer.beginPath()
                try renderer.moveTo(blob.vertices[0] - state.perspective.center)

                for vertex in blob.vertices[1...] {
                    try renderer.lineTo(vertex - state.perspective.center)
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