import VisualAppBase
import WidgetGUI
import CustomGraphicsMath

open class TwoDVoxelRaycastPage: SingleChildWidget {
    private var raycastVisualizer: TwoDRaycastVisualizer
    
    public init() {
        raycastVisualizer = TwoDRaycastVisualizer()    
        raycastVisualizer.raycast = TwoDRaycast(gridSize: AnySize2(100, 100), rayStart: AnyVector2(1, 1), rayEnd: AnyVector2(50, 50))
        super.init(
            child: Background(
                background: Color(0, 120, 240, 255),
                child: Column(children: [
                    Space(size: DSize2(50, 50)),
                    //TextConfigProvider(
                        /*child: */Text("WOWOWOWO!"),
                    /*    config: TextConfig(
                            fontConfig: FontConfig(
                                family: context!.defautFontFamily
                            )
                        )
                    ),*/
                    Button(
                        onClick: { _ in
                            print("BUTTON ON CLICK")
                        },
                        child: Text("WOWOWOWOWOWOWOWOWOWO")
                    ),
                    raycastVisualizer,
                ])
            )
        )
    }

    override open func layout(fromChild: Bool = false) throws {
        child.constraints = constraints
        try child.layout()
        bounds.size = child.bounds.size
    }
}