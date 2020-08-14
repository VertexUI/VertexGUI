import VisualAppBase
import CustomGraphicsMath

public class TextField: Widget {
    lazy private var textInput = TextInput()
    
    public init(_ initialText: String = "", onTextChanged textChangedHandler: ((String) -> ())? = nil) {
        super.init()
        textInput.text = initialText
        if let handler = textChangedHandler {
            _ = onDestroy(textInput.onTextChanged(handler))
        }
    }

    override public func build() {
        children = [
            Padding(all: 8) {
                textInput
            }
        ]
    }

    override public func performLayout() {
        let child = children[0]
        child.constraints = constraints
        child.layout()
        bounds.size = child.bounds.size
    }

    override public func renderContent() -> RenderObject? {
        RenderObject.Container {
            RenderObject.RenderStyle(fillColor: FixedRenderValue(.Green)) {
                RenderObject.Rectangle(globalBounds)
            }
            
            for child in children {
                child.render()
            }
        }
    }
}