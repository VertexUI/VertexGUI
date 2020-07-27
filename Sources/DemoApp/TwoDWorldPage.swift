import VisualAppBase
import WidgetGUI
import CustomGraphicsMath

open class TwoDWorldPage: SingleChildWidget {
    
    override public init() {
        super.init()
    }

    override open func buildChild() -> Widget {
        Background(
                background: Color(0, 120, 240, 255)) {
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
                        /*onClick: { _ in
                            print("BUTTON ON CLICK")
                        },*/
                        child: Text("WOWOWOWOWOWOWOWOWOWO")
                    )
                    TwoDWorldView()
                }
            }
    }

    override open func layout() throws {
        child.constraints = constraints
        try child.layout()
        bounds.size = child.bounds.size
    }
}