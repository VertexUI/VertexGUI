import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

public class ScrollArea: SingleChildWidget {

    private let childBuilder: () -> Widget

    private var scrollXEnabled = true

    private var scrollYEnabled = true

    private var scrollXActive = false

    private var scrollYActive = false

    private var mouseTrackingStartPosition = DVec2.zero

    /// Offset before current mouse track.
    private var previousOffset: DVec2 = .zero

    private var offset: DVec2 = .zero

    private var scrollBarSizes: DSize2 = .zero

    private var scrollBarTranslations: DVec2 {
 
        let scrollBarMoveSpace = DVec2(bounds.size) - DVec2(scrollBarSizes)

        let relativeScrollOffset = -offset / DVec2(child.bounds.size - bounds.size)

        return scrollBarMoveSpace * relativeScrollOffset
    }

    private var xScrollBarBounds: DRect {

        DRect(min: DVec2(scrollBarTranslations.x, bounds.size.height - 20), size: DSize2(scrollBarSizes.width, 20))
    }

    private var yScrollBarBounds: DRect {

        DRect(min: DVec2(bounds.size.width - 20, scrollBarTranslations.y), size: DSize2(20, scrollBarSizes.height))
    }

    public init(@WidgetBuilder child childBuilder: @escaping () -> Widget) {
        
        self.childBuilder = childBuilder
    }    

    override public func buildChild() -> Widget {

        MouseArea {

            childBuilder()

            // TODO: remove empty on click when forward searching closure params comes            
        } onClick: { _ in
        
        } onMouseButtonDown: { [unowned self] in

            if $0.button == .Left {

                let localPosition = $0.position - globalPosition

                scrollXActive = xScrollBarBounds.contains(point: localPosition)

                scrollYActive = yScrollBarBounds.contains(point: localPosition)

                mouseTrackingStartPosition = $0.position
            }

        } onMouseButtonUp: { [unowned self] _ in

            scrollXActive = false

            scrollYActive = false

            previousOffset = offset

            print("MOUSE BUTTON UP!!!!!!!!!!")

        } onMouseMove: { [unowned self] in

            let totalMove = mouseTrackingStartPosition - $0.position

            let offsetBeforeUpdate = offset

            offset = previousOffset

            if scrollXActive {

                offset.x += totalMove.x
            }

            if scrollYActive {

                offset.y += totalMove.y
            }

            if offsetBeforeUpdate != offset {

                invalidateRenderState()
            }

        } onMouseWheel: { [unowned self] in

            offset += $0.scrollAmount * 10

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

        scrollBarSizes.height = constrainedSize.height / (child.bounds.size.height / constrainedSize.height)
        
        scrollBarSizes.width = constrainedSize.width / (child.bounds.size.width / constrainedSize.width)

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