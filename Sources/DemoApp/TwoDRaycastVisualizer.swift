import VisualAppBase
import WidgetGUI
import CustomGraphicsMath

open class TwoDRaycastVisualizer: LeafWidget, GUIMouseEventConsumer {
    public var raycast: TwoDRaycast?

    //public init() {
   //     super.init()
   // }

    override open func layout(fromChild: Bool) {
        bounds.size = constraints!.maxSize
    }

    open func consume(_ event: GUIMouseEvent) throws {
        if let event = event as? GUIMouseButtonClickEvent {
            print("TWO D RAYCAST VISUALIZER CLICK EVENT")
        }
    }

    private func getTileRect(index: IVec2) -> DRect {
        // TODO: optimize/cache tileSize
        let tileSize = DSize2(bounds.size) / DSize2(raycast!.gridSize)
        let topLeft = globalPosition + DVec2(tileSize.width * Double(index.x), tileSize.height * Double(index.y))
        return DRect(topLeft: topLeft, size: tileSize)
    }

    override open func render() -> RenderObject {
        return .CacheSplit([.Custom(id: self.id) { renderer in
            print("MANUAL RAYCAST RENDER")
            //try renderer.translate(DVec2(0, -globalPosition.y))
            try renderer.scale(DVec2(1, -1))
            try renderer.translate(DVec2(0, -(2 * self.globalPosition.y + self.bounds.size.height)))

            if let raycast = self.raycast {
                let scaledRayStart = self.globalPosition + raycast.rayStart / DVec2(raycast.gridSize) * self.bounds.size
                let scaledRayEnd = self.globalPosition + raycast.rayEnd / DVec2(raycast.gridSize) * self.bounds.size
                
                for xIndex in 0..<raycast.gridSize.width {
                    for yIndex in 0..<raycast.gridSize.height {
                        let index = IVec2(xIndex, yIndex)
                        let tileRect = self.getTileRect(index: index)

                        if raycast.testedTiles.contains(index) {
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
                        }
                    }
                }

                for result in raycast.results {
                    let tileRect = self.getTileRect(index: result.tileIndex)
                    try renderer.beginPath()
                    try renderer.fillColor(Color(255, 0, 0, 255))
                    try renderer.rect(tileRect)
                    try renderer.fill()

                    let scale = DVec2(DSize2(self.bounds.size) / DSize2(raycast.gridSize))
                    let vertices = Tile.edgeVertices(topLeft: DVec2(result.tileIndex), vectorLayout: .topLeftToBottomRight)[result.edge]!
                    try renderer.lineSegment(from: self.globalPosition + scale * vertices.0, to: self.globalPosition + scale * vertices.1)
                    try renderer.strokeWidth(10)
                    try renderer.strokeColor(.Blue)
                    try renderer.stroke()
                }

                try renderer.lineSegment(from: scaledRayStart, to: scaledRayEnd)
                try renderer.strokeWidth(2)
                try renderer.strokeColor(.Blue)
                try renderer.stroke()
                try renderer.resetTransform()
                //renderer.translate(DVec2())

                //try renderer.resetTransform() 
                //try renderer.line(from: DVec2(1, 1), to: DVec2(100, 100), width: 2, color: Color(0, 0, 0, 255))
            }
        }])
    }
}