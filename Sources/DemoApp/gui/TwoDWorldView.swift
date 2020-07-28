import VisualAppBase
import WidgetGUI
import CustomGraphicsMath

open class TwoDWorldView: LeafWidget {
    private var world: TwoDVoxelWorld
    private var raycasts: [TwoDRaycast]

    public var highlightedRaycast: TwoDRaycast? {
        didSet {
            invalidateRenderState()
        }
    }

    public init(world: TwoDVoxelWorld, raycasts: [TwoDRaycast]) {
        self.world = world
        self.raycasts = raycasts
        super.init()
    }

    override open func layout() {
        bounds.size = constraints!.maxSize
    }

    private func worldToLocal(position: DVec2) -> DVec2 {
        position / DVec2(world.size) * DVec2(bounds.size)
    }

    private func getTileRect(index: IVec2) -> DRect {
        // TODO: optimize/cache tileSize
        let tileSize = DSize2(bounds.size) / DSize2(world.size)
        let topLeft = globalPosition + DVec2(tileSize.width * Double(index.x), tileSize.height * Double(index.y))
        return DRect(topLeft: topLeft, size: tileSize)
    }

    override open func render() -> RenderObject {
        return .CacheSplit([.Custom(id: self.id) { renderer in
            //print("MANUAL RAYCAST RENDER")
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
                    default:
                        break
                    }
                }

                try renderer.lineSegment(from: scaledRayStart, to: scaledRayEnd)
                try renderer.strokeWidth(5)
                if let highlightedRaycast = self.highlightedRaycast, raycast == highlightedRaycast {
                    try renderer.strokeColor(.Black)
                } else {
                    try renderer.strokeColor(.Blue)
                }
                try renderer.stroke()

                for result in raycast.results {
                    switch result {
                    case .Intersection(let position):
                        try renderer.circle(center: self.worldToLocal(position: position) + self.globalPosition, radius: 5)
                        try renderer.fillColor(Color(230, 200, 255, 255))
                        try renderer.fill()
                    default:
                        break
                    }
                }
            }
        }])
    }
}