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
        _ = onDestroy(textInput.onRenderStateInvalidated { [unowned self] _ in
            invalidateRenderState()
        })
    }

    override public func build() {
        children = [textInput]
    }

    override public func performLayout() {
        textInput.constraints = constraints
        textInput.layout()
        bounds.size = textInput.bounds.size
    }

    override public func renderContent() -> RenderObject? {
        RenderObject.Container {
            RenderObject.RenderStyle(fillColor: FixedRenderValue(.Green)) {
                RenderObject.Rectangle(globalBounds)
            }
            
            textInput.render()
        }
    }
}