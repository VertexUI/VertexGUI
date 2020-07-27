import VisualAppBase
import WidgetGUI
import CustomGraphicsMath

open class TwoDWorldPage: SingleChildWidget {
    private var world: TwoDVoxelWorld = TwoDVoxelWorld(size: ISize2(40, 40))
    private var raycasts: [TwoDRaycast] = []

    private var newRaycastStart: DVec2?
    private var newRaycastEnd: DVec2?

    // TODO: should create a wrapper / optimize / avoid expensive tree traversal
    private var worldView: TwoDWorldView {
        return childOfType(TwoDWorldView.self)!
    }
    
    override public init() {
        super.init()
        print("INIT AFTER")
    }

    override open func buildChild() -> Widget {
        Background(background: Color(0, 120, 240, 255)) {
            Column {
                Space(size: DSize2(50, 50))
                //TextConfigProvider(
                    /*child: */Text("WOWOWOWO!")
                /*    config: TextConfig(
                        fontConfig: FontConfig(
                            family: context!.defautFontFamily
                        )
                    )
                ),*/
                Button(
                    child: Text("WOWOWOWOWOWOWOWOWOWO")
                )
                MouseArea(onClick: handleWorldViewClick(_:)) {
                    TwoDWorldView(world: world, raycasts: raycasts)
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