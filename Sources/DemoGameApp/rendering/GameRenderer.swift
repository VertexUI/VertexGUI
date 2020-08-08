import Foundation
import VisualAppBase
import CustomGraphicsMath

public class GameRenderer {
    private let state: GameState
    private let eventBuffer: GameEventBuffer
    private let eventBufferId: UInt
    private var foodBlobDrawables: [UInt: FoodBlobDrawable] = [:]
    private var playerBlobDrawables: [UInt: PlayerBlobDrawable] = [:]
    
    public init(state: GameState) {
        self.state = state
        eventBuffer = GameEventBuffer()
        eventBufferId = state.register(buffer: eventBuffer)
    }

    deinit {
        state.unregister(bufferId: eventBufferId)
    }

    public func updateRenderState(from perspective: GamePerspective, deltaTime: Double) {
        for event in eventBuffer {
            if case let .Remove(id) = event {
                foodBlobDrawables[id] = nil
                playerBlobDrawables[id] = nil
            }
        }
        eventBuffer.clear()

        for blob in state.playerBlobs.values {
            if let drawable = playerBlobDrawables[blob.id] {
                drawable.blobState = blob
                drawable.update(deltaTime: deltaTime)
            } else {
                playerBlobDrawables[blob.id] = PlayerBlobDrawable(blobState: blob)
            }
        }

        for chunk in state.chunksIn(area: perspective.visibleArea) {
            for blob in chunk.blobs.values {
                if foodBlobDrawables[blob.id] == nil {
                    foodBlobDrawables[blob.id] = FoodBlobDrawable(blobState: blob)
                }
            }
        }
    }

    public func render(from perspective: GamePerspective, in screenArea: DRect, with renderer: Renderer) throws {
        let gameScreenFitScale: Double 
        if screenArea.size.height > screenArea.size.width {
            gameScreenFitScale = screenArea.size.height / perspective.visibleArea.size.height
        } else {
            gameScreenFitScale = screenArea.size.width / perspective.visibleArea.size.width
        }

        try renderer.translate(screenArea.min)
        try renderer.translate(DVec2(screenArea.size / 2))
        try renderer.scale(DVec2(gameScreenFitScale, gameScreenFitScale))
        try renderer.scale(DVec2(1, -1))
    
        for drawable in foodBlobDrawables.values {
            let paddedVisibleArea = DRect(
                min: perspective.visibleArea.min - DVec2(drawable.blobState.radius, drawable.blobState.radius),
                max: perspective.visibleArea.max - DVec2(drawable.blobState.radius, drawable.blobState.radius))
            
            if !paddedVisibleArea.contains(point: drawable.blobState.position) {
                continue
            }

            try renderVertices(vertices: drawable.vertices, from: perspective, with: renderer)
        }

        for drawable in playerBlobDrawables.values {
            let paddedVisibleArea = DRect(
                min: perspective.visibleArea.min - DVec2(drawable.blobState.radius, drawable.blobState.radius),
                max: perspective.visibleArea.max - DVec2(drawable.blobState.radius, drawable.blobState.radius))
            
            if !paddedVisibleArea.contains(point: drawable.blobState.position) {
                continue
            }

            try renderVertices(vertices: drawable.vertices, from: perspective, with: renderer)
        }
    }

    private func renderVertices(vertices: [DPoint2], from perspective: GamePerspective, with renderer: Renderer) throws {
        if vertices.count > 0 {

            try renderer.beginPath()
            try renderer.moveTo(vertices[0] - perspective.center)

            for vertex in vertices[1...] {
                try renderer.lineTo(vertex - perspective.center)
            }
            
            try renderer.closePath()

            try renderer.fillColor(.Green)
            
            //try renderer.strokeColor(.Green)
            //try renderer.strokeWidth(2)
            //try renderer.stroke()
            try renderer.fill()
        }
    }
}