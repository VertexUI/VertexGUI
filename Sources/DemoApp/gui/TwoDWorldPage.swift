import VisualAppBase
import WidgetGUI
import CustomGraphicsMath

open class TwoDWorldPage: SingleChildWidget {
    private var world: TwoDVoxelWorld = TwoDVoxelWorld(size: ISize2(40, 40))
    private var raycasts: [TwoDRaycast] = []

    private var newRaycastStart: DVec2?
    private var newRaycastEnd: DVec2?

    private var selectedRaycast: TwoDRaycast?

    // TODO: should create a wrapper / optimize / avoid expensive tree traversal
    private var worldView: TwoDWorldView {
        return childOfType(TwoDWorldView.self)!
    }
    
    override public init() {
        super.init()
    }

    override open func buildChild() -> Widget {
        Background(background: Color(120, 160, 255, 255)) {
            Row {                
                Column {
                    Padding(all: 20) {
                    //TextConfigProvider(
                        /*child: */Text("2D Raycast Visualizer")
                    /*    config: TextConfig(
                            fontConfig: FontConfig(
                                family: context!.defautFontFamily
                            )
                        )
                    ),*/
                    }
                    Padding(all: 20) {
                        Button(
                            child: Text("Button without function")
                        )
                    }
                    ComputedSize {
                        $0.constrain(DSize2($0.maxWidth * 0.75, $0.maxHeight))
                    } child: {
                        MouseArea(onClick: handleWorldViewClick(_:)) {
                            TwoDWorldView(world: world, raycasts: raycasts)
                        }
                    }
                }

                ComputedSize {
                    $0.constrain(DSize2($0.maxWidth, $0.maxHeight))
                } child: {

                    Padding(all: 20) {

                        if let selectedRaycast = selectedRaycast {
                            
                            RaycastDetailView(raycast: selectedRaycast)

                        } else {
                            
                            MouseArea(onMouseLeave: { _ in
                                self.worldView.highlightedRaycast = nil
                                print("MOUSE LEAVE")
                            }) {
                                Column(spacing: 20) {
                                    
                                    Text("Raycasts")

                                    raycasts.map { raycast in

                                        MouseArea(onClick: { _ in
                                            self.selectedRaycast = raycast
                                            self.invalidateChild()
                                        }, onMouseEnter: { _ in
                                            print("MOUSE ENTER")
                                            self.worldView.highlightedRaycast = raycast
                                        }) {
                                            Row(spacing: 20, wrap: true) {

                                                Text("Raycast")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func localToWorld(_ position: DVec2) -> DVec2 {
        return position / DVec2(worldView.bounds.size) * DVec2(world.size)
    }

    open func handleWorldViewClick(_ event: GUIMouseButtonClickEvent) throws {
        if event.button == .Left {
            let localPosition = event.position - worldView.globalBounds.topLeft
            let worldPosition = localToWorld(localPosition)
            if newRaycastStart == nil {
                newRaycastStart = worldPosition
            } else if newRaycastEnd == nil {
                newRaycastEnd = worldPosition
                raycasts.append(world.raycast(from: newRaycastStart!, to: newRaycastEnd!))
                invalidateChild()
                newRaycastStart = nil
                newRaycastEnd = nil
            }
        }
    }

    override open func layout() throws {
        child.constraints = constraints
        try child.layout()
        bounds.size = child.bounds.size
    }
}