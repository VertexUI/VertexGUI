import Foundation
import VisualAppBase
import CustomGraphicsMath
import GLGraphicsMath
import GL

public class GameRenderer {
    private let state: PlayerState
    private let eventBuffer: GameEventBuffer
    private let eventBufferId: UInt
    private var foodBlobDrawables: [UInt: FoodBlobDrawable] = [:]
    private var playerBlobDrawables: [UInt: PlayerBlobDrawable] = [:]

    private var foodShaderProgram = FoodShaderProgram()
    private var foodColor = Color.Green
    private var foodVao = GLMap.UInt()
    private var foodVerticesVbo = GLMap.UInt()
    private var foodVertices: [GLMap.Float] = {
        var vertices = [GLMap.Float]()
        let triangleCount = 10 
        for i in 0..<triangleCount {
            vertices.append(0)
            vertices.append(0)
            let nextVertexAngle = GLMap.Float.pi * 2 * GLMap.Float(i + 1) / GLMap.Float(triangleCount)
            vertices.append(cos(nextVertexAngle))
            vertices.append(sin(nextVertexAngle))
            let startVertexAngle = GLMap.Float.pi * 2 * GLMap.Float(i) / GLMap.Float(triangleCount)
            vertices.append(cos(startVertexAngle))
            vertices.append(sin(startVertexAngle))
        }
        return vertices
    }()
    private var foodPositionsVbo = GLMap.UInt()

    private var playerShaderProgram = PlayerShaderProgram()
    private var playerColor = Color(180, 120, 255, 255)
    private var playerVao = GLMap.UInt()
    private var playerVerticesVbo = GLMap.UInt()

    public init(state: PlayerState) {
        self.state = state
        eventBuffer = GameEventBuffer()
        eventBufferId = 0
        //eventBufferId = state.register(buffer: eventBuffer)

        // GL setup for food        
        try! foodShaderProgram.compile()

        glGenVertexArrays(1, &foodVao)
        glBindVertexArray(foodVao)

        glGenBuffers(1, &foodVerticesVbo)
        glBindBuffer(GLMap.ARRAY_BUFFER, foodVerticesVbo)
        glBufferData(GLMap.ARRAY_BUFFER, foodVertices.count * MemoryLayout<GLMap.Float>.size, foodVertices, GLMap.STATIC_DRAW)

        glEnableVertexAttribArray(0)
        glVertexAttribPointer(0, 2, GLMap.FLOAT, false, GLMap.Size(MemoryLayout<GLMap.Float>.size * 2), nil)

        glGenBuffers(1, &foodPositionsVbo)
        glBindBuffer(GLMap.ARRAY_BUFFER, foodPositionsVbo)

        glEnableVertexAttribArray(1)
        glVertexAttribPointer(1, 2, GLMap.FLOAT, false, GLMap.Size(MemoryLayout<GLMap.Float>.size * 2), nil)
        glVertexAttribDivisor(1, 1)

        glBindVertexArray(0)
        glBindBuffer(GLMap.ARRAY_BUFFER, 0)

        // GL setup for player
        try! playerShaderProgram.compile()

        glGenVertexArrays(1, &playerVao)
        glBindVertexArray(playerVao)

        glGenBuffers(1, &playerVerticesVbo)
        glBindBuffer(GLMap.ARRAY_BUFFER, playerVerticesVbo)

        glEnableVertexAttribArray(0)
        glVertexAttribPointer(0, 2, GLMap.FLOAT, false, GLMap.Size(MemoryLayout<GLMap.Float>.size * 2), nil)

        glBindVertexArray(0)
        glBindBuffer(GLMap.ARRAY_BUFFER, 0)
    }

    deinit {
        //state.unregister(bufferId: eventBufferId)
    }

    public func render(renderArea: DRect, window: Window, renderer: Renderer, deltaTime: Double) throws {      
        updateRenderState(deltaTime: deltaTime)

        let perspective = state.player.perspective
        
        let gameScreenFitScale: DVec2 
        if renderArea.size.height > renderArea.size.width {
            let targetRatio = perspective.visibleArea.size.width / perspective.visibleArea.size.height
            let scaleX = targetRatio / (renderArea.size.width / renderArea.size.height)
            gameScreenFitScale = DVec2(scaleX, 1)
        } else {
            let targetRatio = perspective.visibleArea.size.height / perspective.visibleArea.size.width
            let scaleY = targetRatio / (renderArea.size.height / renderArea.size.width)
            gameScreenFitScale = DVec2(1, scaleY)
        }

        glViewport(
            GLMap.Int(renderArea.min.x),
            GLMap.Int(window.size.height - renderArea.max.y),
            GLMap.Size(renderArea.size.width),
            GLMap.Size(renderArea.size.height))
        /*try renderer.translate(screenArea.min)
        try renderer.translate(DVec2(screenArea.size / 2))
        try renderer.scale(DVec2(gameScreenFitScale, gameScreenFitScale))
        try renderer.scale(DVec2(1, -1))*/
        
        var foodCount = 0
        // TODO: might need radius as instanced vertex attribute for each food
        var foodRadius: GLMap.Float = 0
        var foodPositions: [GLMap.Float] = []

        for drawable in foodBlobDrawables.values {
            let paddedVisibleArea = DRect(
                min: perspective.visibleArea.min - DVec2(drawable.blobState.radius, drawable.blobState.radius),
                max: perspective.visibleArea.max - DVec2(drawable.blobState.radius, drawable.blobState.radius))
            
            if !paddedVisibleArea.contains(point: drawable.blobState.position) {
                continue
            }

            //try renderVertices(vertices: drawable.vertices, from: perspective, with: renderer)
            foodPositions.append(GLMap.Float(drawable.blobState.position.x))
            foodPositions.append(GLMap.Float(drawable.blobState.position.y))
            foodRadius = GLMap.Float(drawable.blobState.radius)
            foodCount += 1
        }

        // TODO: display in correct width/height ratio
        foodShaderProgram.use()
        glUniform2f(
            foodShaderProgram.uniformPerspectiveMinLocation,
            GLMap.Float(perspective.visibleArea.min.x),
            GLMap.Float(perspective.visibleArea.min.y))
        glUniform2f(
            foodShaderProgram.uniformPerspectiveMaxLocation,
            GLMap.Float(perspective.visibleArea.max.x),
            GLMap.Float(perspective.visibleArea.max.y))
        glUniform2f(
            foodShaderProgram.uniformScalingLocation,
            GLMap.Float(gameScreenFitScale.x),
            GLMap.Float(gameScreenFitScale.y)
        )
        glUniform1f(
            foodShaderProgram.uniformRadiusLocation,
            foodRadius
        )
        glUniform4f(
            foodShaderProgram.uniformColorLocation,
            foodColor.glR,
            foodColor.glG,
            foodColor.glB,
            foodColor.glA
        )
        glBindVertexArray(foodVao)
        glBindBuffer(GLMap.ARRAY_BUFFER, foodPositionsVbo)
        glBufferData(GLMap.ARRAY_BUFFER, foodPositions.count * MemoryLayout<GLMap.Float>.size, foodPositions, GLMap.DYNAMIC_DRAW)
        glDrawArraysInstanced(GLMap.TRIANGLES, 0, GLMap.Size(foodVertices.count), GLMap.Size(foodCount))


        var playerVertices: [GLMap.Float] = []

        for drawable in playerBlobDrawables.values {
            let paddedVisibleArea = DRect(
                min: perspective.visibleArea.min - DVec2(drawable.blobState.radius, drawable.blobState.radius),
                max: perspective.visibleArea.max - DVec2(drawable.blobState.radius, drawable.blobState.radius))
            
            if !paddedVisibleArea.contains(point: drawable.blobState.position) {
                continue
            }

            /*try renderVertices(vertices: drawable.vertices, from: perspective, with: renderer)
            try renderer.beginPath()
            try renderer.circle(center: drawable.blobState.position - perspective.center, radius: drawable.blobState.radius)
            try renderer.strokeColor(.Black)
            try renderer.strokeWidth(1)
            try renderer.stroke()*/

            for i in 0..<drawable.vertices.count {
                playerVertices.append(GLMap.Float(drawable.blobState.position.x))
                playerVertices.append(GLMap.Float(drawable.blobState.position.y))
                playerVertices.append(GLMap.Float(drawable.vertices[(i + 1) % drawable.vertices.count].x))
                playerVertices.append(GLMap.Float(drawable.vertices[(i + 1) % drawable.vertices.count].y))
                playerVertices.append(GLMap.Float(drawable.vertices[i].x))
                playerVertices.append(GLMap.Float(drawable.vertices[i].y))
            }
        }

        playerShaderProgram.use()
        glUniform2f(
            playerShaderProgram.uniformPerspectiveMinLocation,
            GLMap.Float(perspective.visibleArea.min.x),
            GLMap.Float(perspective.visibleArea.min.y))
        glUniform2f(
            playerShaderProgram.uniformPerspectiveMaxLocation,
            GLMap.Float(perspective.visibleArea.max.x),
            GLMap.Float(perspective.visibleArea.max.y))
        glUniform2f(
            playerShaderProgram.uniformScalingLocation,
            GLMap.Float(gameScreenFitScale.x),
            GLMap.Float(gameScreenFitScale.y)
        )
        glUniform4f(
            playerShaderProgram.uniformColorLocation,
            playerColor.glR,
            playerColor.glG,
            playerColor.glB,
            playerColor.glA
        )
        glBindVertexArray(playerVao)
        glBindBuffer(GLMap.ARRAY_BUFFER, playerVerticesVbo)
        glBufferData(GLMap.ARRAY_BUFFER, playerVertices.count * MemoryLayout<GLMap.Float>.size, playerVertices, GLMap.DYNAMIC_DRAW)
        glDrawArrays(GLMap.TRIANGLES, 0, GLMap.Size(Double(playerVertices.count) / 2))
    }

    private func updateRenderState(deltaTime: Double) {
        /*for event in eventBuffer {
            if case let .Remove(id) = event {
                foodBlobDrawables[id] = nil
                playerBlobDrawables[id] = nil
            }
        }
        eventBuffer.clear()*/

        updateRenderState(for: state.player, deltaTime: deltaTime)

        for blob in state.otherPlayers.values {
            updateRenderState(for: blob, deltaTime: deltaTime)
        }
        
        for blob in state.foods.values {
            updateRenderState(for: blob, deltaTime: deltaTime)
        }
    }

    private func updateRenderState(for blob: PlayerBlob, deltaTime: Double) {
        if let drawable = playerBlobDrawables[blob.id] {
            drawable.blobState = blob
            drawable.update(deltaTime: deltaTime)
        } else {
            playerBlobDrawables[blob.id] = PlayerBlobDrawable(blobState: blob)
        }
    }

    private func updateRenderState(for blob: FoodBlob, deltaTime: Double) {
        if foodBlobDrawables[blob.id] == nil {
            foodBlobDrawables[blob.id] = FoodBlobDrawable(blobState: blob)
        }
    }

    /*private func renderVertices(vertices: [DPoint2], from perspective: GamePerspective, with renderer: Renderer) throws {
        if vertices.count > 0 {

            try renderer.beginPath()
            try renderer.moveTo(vertices[0] - perspective.center + DVec2(400, 400))

            for vertex in vertices[1...] {
                try renderer.lineTo(vertex - perspective.center + DVec2(400, 400))
            }
            
            try renderer.closePath()

            try renderer.fillColor(.Green)
            
            //try renderer.strokeColor(.Green)
            //try renderer.strokeWidth(2)
            //try renderer.stroke()
            try renderer.fill()
        }
    }*/
}