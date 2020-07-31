import VisualAppBase
import WidgetGUI
import CustomGraphicsMath

public class ChildViewOne: SingleChildWidget {
    private var content: Observable<String>
    
    public init(content: Observable<String>) {
        self.content = content
        super.init()
        _ = self.content.onChanged { _ in
            self.invalidateRenderState()
        }
    }

    override open func buildChild() -> Widget {
        Button(onClick: { [unowned self] _ in
            self.content.value = "Content from ChildViewOne"
        }) {
            Text("Click to change content")
        }
    }

    override open func performLayout() {
        bounds.size = bounds.size + DSize2(0, 60)
    }

    override open func renderContent() -> RenderObject? {
        RenderObject.Container {
            child.render()

            RenderObject.Text("ChildViewOne", fontConfig: FontConfig(
                family: defaultFontFamily,
                size: 16,
                weight: .Regular,
                style: .Normal
            ), color: .Black, topLeft: globalPosition + DVec2(child.bounds.size), wrap: false)

            RenderObject.Text("\(content.value)", fontConfig: FontConfig(
                family: defaultFontFamily,
                size: 16,
                weight: .Regular,
                style: .Normal
            ), color: .Black, topLeft: globalPosition + DVec2(child.bounds.size) + DVec2(0, 20), wrap: false)
        }
    }

    override open func destroySelf() {
        content.onChanged.removeAllHandlers()
    }
}
