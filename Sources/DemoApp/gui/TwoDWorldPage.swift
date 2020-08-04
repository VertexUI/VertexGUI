import VisualAppBase
import WidgetGUI
import CustomGraphicsMath

open class TwoDWorldPage: SingleChildWidget {
    private var world: TwoDVoxelWorld = TwoDVoxelWorld(size: ISize2(40, 40))
    private var raycasts = ObservableArray<TwoDRaycast>()

    private var selectedRaycast = Observable<TwoDRaycast?>(nil)
    private var highlightedRaycast = Observable<TwoDRaycast?>(nil)

    public init() {
        super.init()
    }

    // TODO: should create a wrapper / optimize / avoid expensive tree traversal
    private var worldView: TwoDWorldView {
        return childOfType(TwoDWorldView.self)!
    }
    
    override open func buildChild() -> Widget {
        Background(background: Color(120, 160, 255, 255)) { [unowned self] in
            Row {                
                Column {
                    Padding(all: 20) {
                        Text("2D Raycast Visualizer")
                    }
                    Padding(all: 20) {
                        Button(child: {
                            Text("Button without function")
                        })
                    }
                    ComputedSize {
                        TwoDWorldView(
                            world: world,
                            raycasts: raycasts,
                            highlightedRaycast: highlightedRaycast)
                    } calculate: {
                        BoxConstraints(size: $0.constrain(DSize2($0.maxWidth * 0.75, $0.maxHeight)))
                    }
                }

                ComputedSize {

                    Padding(all: 20) {

                        ForwardingObservingBuilder(observe: selectedRaycast) { selectedRaycastValue in

                            if let selectedRaycast = selectedRaycast.value {
                                
                                Column {
                                    Button {
                                        Text("Close")
                                    } onClick: { _ in
                                        self.selectedRaycast.value = nil
                                    } 

                                    RaycastDetailView(raycast: selectedRaycast)
                                }

                            } else {

                                ObservingBuilder([AnyObservable(highlightedRaycast), AnyObservable(raycasts)]) {
                                    
                                    MouseArea(onMouseLeave: { _ in
                                        highlightedRaycast.value = nil
                                    }) {
                                        Column(spacing: 20) {
                                            
                                            Text("Raycasts")

                                            raycasts.map { raycast in
                                            
                                                MouseArea(onClick: { _ in
                                                    self.selectedRaycast.value = raycast
                                                }, onMouseEnter: { _ in
                                                    highlightedRaycast.value = raycast
                                                }) {
                                                    Background(background: .Red) {
                                                        Padding(all: 16) {
                                                            Row(spacing: 20, wrap: true) {
                                                                
                                                                if raycast == highlightedRaycast.value {
                                                                    Text("HIGHLIGHTED")
                                                                }

                                                                MouseInteraction {
                                                                    Text("Raycast")
                                                                } hover: {
                                                                    Text("Raycast on HOVER!!")
                                                                } active: {
                                                                    Text("Raycast on ACTIVE!!")
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
                    }
                } calculate: {
                    BoxConstraints(size: $0.constrain(DSize2($0.maxWidth, $0.maxHeight)))
                }
            }
        }
    }

    override open func performLayout() {
        child.constraints = constraints
        try child.layout()
        bounds.size = child.bounds.size
    }
}
