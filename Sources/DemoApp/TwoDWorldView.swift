import VisualAppBase
import WidgetGUI
import CustomGraphicsMath

open class TwoDWorldView: LeafWidget, GUIMouseEventConsumer {
    private var world: TwoDVoxelWorld = TwoDVoxelWorld(size: ISize2(40, 40))
    private var raycasts: [TwoDRaycast] = []

    private var newRaycastStart: DVec2?
    private var newRaycastEnd: DVec2?

    override open func layout() {
        bounds.size = constraints!.maxSize
    }

    private func localToWorld(_ position: DVec2) -> DVec2 {
        return position / DVec2(bounds.size) * DVec2(world.size)
    }

    open func consume(_ event: GUIMouseEvent) throws {
        if let event = event as? GUIMouseButtonClickEvent {
            if event.button == .Left {
                let localPosition = event.position - globalPosition
                let worldPosition = localToWorld(localPosition)
                if newRaycastStart == nil {
                    newRaycastStart = worldPosition
                } else if newRaycastEnd == nil {
                    newRaycastEnd = worldPosition
                    raycasts.append(world.raycast(from: newRaycastStart!, to: newRaycastEnd!))
                    invalidateRenderState()
                    print("DID PERFORM RAYCAST")
                    newRaycastStart = nil
                    newRaycastEnd = nil
                }
            }
            print("TWO D RAYCAST VISUALIZER CLICK EVENT")
        } else if let event = event as? GUIMouseButtonDownEvent {
            print("TWO D RAYCAST MOUSE BUTTON DOWN EVENT")
        } else if let event = event as? GUIMouseButtonUpEvent {
            print("TWO D RAYCAST MOUSE BUTTON UP EVENT")
        } else if let event = event as? GUIMouseMoveEvent {
            print("TWO D RAYCAST MOUSE MOVE EVENT")
        }
    }

    private func getTileRect(index: IVec2) -> DRect {
        // TODO: optimize/cache tileSize
        let tileSize = DSize2(bounds.size) / DSize2(world.size)
        let topLeft = globalPosition + DVec2(tileSize.width * Double(index.x), tileSize.height * Double(index.y))
        return DRect(topLeft: topLeft, size: tileSize)
    }

    override open func render() -> RenderObject {
        return .CacheSplit([.Custom(id: self.id) { renderer in
            print("MANUAL RAYCAST RENDER")
            try renderer.scale(DVec2(1, -1))
            try renderer.translate(DVec2(0, -(2 * self.globalPosition.y + self.bounds.size.height)))
            
            for xIndex in 0..<self.world.size.width {
                for yIndex in 0..<self.world.size.height {
                    let index = IVec2(xIndex, yIndex)
                    let tileRect = self.getTileRect(index: index)

                    let fillColor = ((yIndex % 2 == 0 ? 1 : 0) + xIndex) % 2 == 0 ? Color(240, 240, 240, 255) : Color.White
                    try renderer.beginPath()
                    try renderer.fillColor(fillColor)
                    try renderer.rect(tileRect)
                    try renderer.fill()

                    /*if raycast.testedTiles.contains(index) {
                        try renderer.beginPath()
                        try renderer.fillColor(Color(0, 255, 0, 255))
                        try renderer.rect(tileRect)
                        try renderer.fill()
                    } else {
                        let fillColor = ((yIndex % 2 == 0 ? 1 : 0) + xIndex) % 2 == 0 ? Color(240, 240, 240, 255) : Color.White
                        try renderer.beginPath()
                        try renderer.fillColor(fillColor)
                        try renderer.rect(tileRect)
                        try renderer.fill()
                    }*/
                }
            }

            try renderer.resetTransform()
            
            for raycast in self.raycasts {
                let scaledRayStart = self.globalPosition + raycast.start / DVec2(self.world.size) * self.bounds.size
                let scaledRayEnd = self.globalPosition + raycast.end / DVec2(self.world.size) * self.bounds.size

                for result in raycast.results {
                    switch result {
                    case .Test(let tileIndex):
                        let tileRect = self.getTileRect(index: tileIndex)
                        let fillColor = Color.Blue.adjusted(alpha: 50)
                        try renderer.beginPath()
                        try renderer.fillColor(fillColor)
                        try renderer.rect(tileRect)
                        try renderer.fill()
                    case .Hit(let tileIndex, let edge):
                        let tileRect = self.getTileRect(index: tileIndex)
                        try renderer.beginPath()
                        try renderer.fillColor(Color(255, 0, 0, 255))
                        try renderer.rect(tileRect)
                        try renderer.fill()

                        let scale = DVec2(DSize2(self.bounds.size) / DSize2(self.world.size))
                        let vertices = Tile.edgeVertices(topLeft: DVec2(tileIndex), vectorLayout: .topLeftToBottomRight)[edge]!
                        try renderer.lineSegment(from: self.globalPosition + scale * vertices.0, to: self.globalPosition + scale * vertices.1)
                        try renderer.strokeWidth(10)
                        try renderer.strokeColor(.Yellow)
                        try renderer.stroke()
                    }
                }

                try renderer.lineSegment(from: scaledRayStart, to: scaledRayEnd)
                try renderer.strokeWidth(5)
                try renderer.strokeColor(.Blue)
                try renderer.stroke()

                //renderer.translate(DVec2())

                //try renderer.resetTransform() 
                //try renderer.line(from: DVec2(1, 1), to: DVec2(100, 100), width: 2, color: Color(0, 0, 0, 255))
            }
        }])
    }
}