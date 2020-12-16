import VisualAppBase
import WidgetGUI
import GfxMath

open class TwoDWorldView: Widget, GUIMouseEventConsumer, StatefulWidget {
    public struct State {
        public var highlightedRaycastSetFromInside = false
    }

    public var state: State = State()

    private var world: TwoDVoxelWorld
    private var raycasts: ObservableArray<TwoDRaycast>

    private var newRaycastStart: DVec2?
    private var newRaycastEnd: DVec2?

    public var highlightedRaycast: ObservableProperty<TwoDRaycast?>

    private var mouseThrottle = 0

    public init(
        world: TwoDVoxelWorld,
        raycasts: ObservableArray<TwoDRaycast>,
        highlightedRaycast: ObservableProperty<TwoDRaycast?>
        /*onRaycastHover raycastHoverHandler: @escaping (_ raycast: TwoDRaycast?) -> Void*/) {
            self.world = world
            self.raycasts = raycasts
            self.highlightedRaycast = highlightedRaycast
            //_ = self.onRaycastHover.addHandler(raycastHoverHandler)
            super.init()
    }

    override open func performLayout(constraints: BoxConstraints) -> DSize2 {
        
        constraints.constrain(DSize2(800, 800))
    }

    private func worldToLocal(position: DVec2) -> DVec2 {
        position / DVec2(world.size) * DVec2(bounds.size)
    }

    private func localToWorld(position: DVec2) -> DVec2 {
        position / DVec2(bounds.size) * DVec2(world.size)
    }

    public func handleClick(_ event: GUIMouseButtonClickEvent) {
        if event.button == .Left {
            let localPosition = event.position - globalBounds.min
            let worldPosition = localToWorld(position: localPosition)
            if newRaycastStart == nil {
                newRaycastStart = worldPosition
            } else if newRaycastEnd == nil {
                newRaycastEnd = worldPosition
                raycasts.append(world.raycast(from: newRaycastStart!, to: newRaycastEnd!))
                invalidateRenderState()
                newRaycastStart = nil
                newRaycastEnd = nil
            }
        }
    }

    public func consume(_ event: GUIMouseEvent) {
        print("CALL CONSUME ON MOUSE EVENT", destroyed)

        if let event = event as? GUIMouseButtonClickEvent {
            handleClick(event)
        }

        mouseThrottle += 1
        if mouseThrottle > 5 {
            mouseThrottle = 0
            if let event = event as? GUIMouseMoveEvent {
                let mousePosition = localToWorld(position: event.position)
                for raycast in raycasts {
                    let line1 = AnyLine(from: raycast.start, to: raycast.end)
                    let line2 = AnyLine(point: mousePosition, direction: DVec2(line1.direction.y * -1, line1.direction.x))
                    //print("LINE 1", line1)
                    //print("LINE 2", line2)
                    let intersection = line1.intersect(line: line2)!
                    let distance = (mousePosition - intersection).length
                    print("INTERSECTION", intersection, "DISTANCE", distance)
                    if distance < 4 {
                        highlightedRaycast.value = raycast
                        //try onRaycastHover.invokeHandlers(raycast)
                        state.highlightedRaycastSetFromInside = true
                        invalidateRenderState()
                        return
                    }
                }

                if state.highlightedRaycastSetFromInside {
                    print("REMOVE RAYCAST")
                    //try onRaycastHover.invokeHandlers(nil)
                    state.highlightedRaycastSetFromInside = false
                    highlightedRaycast.value = nil
                    invalidateRenderState()
                }
            }
        }
    }

    private func getTileRect(index: IVec2) -> DRect {
        // TODO: optimize/cache tileSize
        let tileSize = DSize2(bounds.size) / DSize2(world.size)
        let topLeft = globalPosition + DVec2(tileSize.width * Double(index.x), tileSize.height * Double(index.y))
        return DRect(min: topLeft, size: tileSize)
    }

    override open func renderContent() -> RenderObject {
        return .CacheSplit([.Custom(id: self.id) { renderer in
            renderer.scale(DVec2(1, -1))
            renderer.translate(DVec2(0, -(2 * self.globalPosition.y + self.bounds.size.height)))
            
            for xIndex in 0..<self.world.size.width {
                for yIndex in 0..<self.world.size.height {
                    let index = IVec2(xIndex, yIndex)
                    let tileRect = self.getTileRect(index: index)

                    let fillColor = ((yIndex % 2 == 0 ? 1 : 0) + xIndex) % 2 == 0 ? Color(240, 240, 240, 255) : Color.white
                    renderer.beginPath()
                    renderer.fillColor(fillColor)
                    renderer.rectangle(tileRect)
                    renderer.fill()
                }
            }

            renderer.resetTransform()
            
            for raycast in self.raycasts {
                let scaledRayStart = self.globalPosition + raycast.start / DVec2(self.world.size) * self.bounds.size
                let scaledRayEnd = self.globalPosition + raycast.end / DVec2(self.world.size) * self.bounds.size

                for result in raycast.results {
                    switch result {
                    case .Test(let tileIndex):
                        let tileRect = self.getTileRect(index: tileIndex)
                        let fillColor = Color.blue.adjusted(alpha: 50)
                        renderer.beginPath()
                        renderer.fillColor(fillColor)
                        renderer.rectangle(tileRect)
                        renderer.fill()
                    case .Hit(let tileIndex, let edge):
                        let tileRect = self.getTileRect(index: tileIndex)
                        renderer.beginPath()
                        renderer.fillColor(Color(255, 0, 0, 255))
                        renderer.rectangle(tileRect)
                        renderer.fill()

                        let scale = DVec2(DSize2(self.bounds.size) / DSize2(self.world.size))
                        let vertices = Tile.edgeVertices(topLeft: DVec2(tileIndex), vectorLayout: .topLeftToBottomRight)[edge]!
                        renderer.lineSegment(from: self.globalPosition + scale * vertices.0, to: self.globalPosition + scale * vertices.1)
                        renderer.strokeWidth(10)
                        renderer.strokeColor(.yellow)
                        renderer.stroke()
                    default:
                        break
                    }
                }

                renderer.lineSegment(from: scaledRayStart, to: scaledRayEnd)
                renderer.strokeWidth(5)
                if let highlightedRaycast = self.highlightedRaycast.value, raycast == highlightedRaycast {
                    renderer.strokeColor(.black)
                } else {
                    renderer.strokeColor(.blue)
                }
                renderer.stroke()

                for result in raycast.results {
                    switch result {
                    case .Intersection(let position):
                        renderer.circle(center: self.worldToLocal(position: position) + self.globalPosition, radius: 5)
                        renderer.fillColor(Color(230, 200, 255, 255))
                        renderer.fill()
                    default:
                        break
                    }
                }
            }
        }])
    }
}
