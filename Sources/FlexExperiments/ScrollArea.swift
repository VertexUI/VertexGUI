import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

public class ScrollArea: SingleChildWidget {

    private let childBuilder: () -> Widget

    private var scrollXEnabled = true

    private var scrollYEnabled = true 

    private var offset: DVec2 = .zero

    private var xScrollBarBounds: DRect = DRect(min: .zero, size: .zero)
    
    private var yScrollBarBounds: DRect = DRect(min: .zero, size: .zero)

    public init(@WidgetBuilder child childBuilder: @escaping () -> Widget) {
        
        self.childBuilder = childBuilder
    }    

    override public func buildChild() -> Widget {

        MouseArea {

            childBuilder()

            // TODO: remove empty on click when forward searching closure params comes            
        } onClick: { _ in } onMouseMove: { [unowned self] in
            
            offset += $0.move

            invalidateRenderState()
        }
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        let childConstraints = BoxConstraints(

            minSize: .zero,
            
            maxSize: .infinity
        )

        child.layout(constraints: childConstraints)
        
        let constrainedSize = constraints.constrain(child.bounds.size)

        scrollYEnabled = constrainedSize.height < child.bounds.size.height
        
        scrollXEnabled = constrainedSize.width < child.bounds.size.width

        yScrollBarBounds = DRect(min: DVec2(constrainedSize.width - 20, 0), size: DSize2(20, constrainedSize.height))

        xScrollBarBounds = DRect(min: DVec2(0, constrainedSize.height - 20), size: DSize2(constrainedSize.width, 20))

        return constrainedSize
    }

    override public func renderContent() -> RenderObject? { 

        return RenderObject.Container {

            RenderObject.Translation(offset) {

                child.render()
            }

            RenderObject.RenderStyle(fillColor: .Blue) {

                if scrollXEnabled {

                    RenderObject.Rectangle(xScrollBarBounds.translated(globalPosition))
                }

                if scrollYEnabled {
                    
                    RenderObject.Rectangle(yScrollBarBounds.translated(globalPosition))
                }
            }
        }
    }
}