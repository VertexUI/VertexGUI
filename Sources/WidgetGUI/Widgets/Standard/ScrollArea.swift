import CustomGraphicsMath
import VisualAppBase

public class ScrollArea: SingleChildWidget, GUIMouseEventConsumer {

    private let childBuilder: () -> Widget


    private var scrollXEnabled = true

    private var scrollYEnabled = true

    private var scrollXActive = false

    private var scrollYActive = false


    private var mouseTrackingStartPosition = DVec2.zero


    /// Offset before current mouse track.
    private var previousOffset: DVec2 = .zero

    private var previousScrollProgress: DVec2 = .zero

    private var scrollProgress: DVec2 = .zero {

        didSet {

            if scrollProgress.x < 0 {

                scrollProgress.x = 0
            } else if scrollProgress.x > 1 {

                scrollProgress.x = 1
            }

            if scrollProgress.y < 0 {

                scrollProgress.y = 0
            } else if scrollProgress.y > 1 {
                scrollProgress.y = 1
            }
        }
    }

    private var maxOffsets: DVec2 {
        
        DVec2(child.bounds.size - bounds.size) + DVec2(scrollYEnabled ? scrollBarWidths.y : 0, scrollXEnabled ? scrollBarWidths.x : 0)
    }

    private var offsets: DVec2 {
        
        maxOffsets * scrollProgress
    }


    private var scrollBarLengths: DSize2 = .zero

    private var scrollBarWidths = DSize2(20, 20)

    private var maxScrollBarTranslations: DVec2 {

        DVec2(bounds.size - scrollBarLengths) - DVec2(scrollYEnabled ? scrollBarWidths.y : 0, 0)
    }

    private var scrollBarTranslations: DVec2 {
        
        maxScrollBarTranslations * scrollProgress
    }

    private var xScrollBarBounds: DRect {

        DRect(min: DVec2(scrollBarTranslations.x, bounds.size.height - scrollBarWidths.x), size: DSize2(scrollBarLengths.x, scrollBarWidths.x))
    }

    private var yScrollBarBounds: DRect {

        DRect(min: DVec2(bounds.size.width - scrollBarWidths.y, scrollBarTranslations.y), size: DSize2(scrollBarWidths.y, scrollBarLengths.y))
    }


    public init(@WidgetBuilder child childBuilder: @escaping () -> Widget) {
        
        self.childBuilder = childBuilder
    }    

    override public func buildChild() -> Widget {

        childBuilder()
    }

    override public func getBoxConfig() -> BoxConfig {

        BoxConfig(preferredSize: child.boxConfig.preferredSize + DSize2(scrollBarWidths.y, scrollBarWidths.x))
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        let childConstraints = BoxConstraints(

            minSize: .zero,
            
            maxSize: .infinity
        )

        child.layout(constraints: childConstraints)
        
        updateEnabledDimensions(maxOwnSize: constraints.maxSize, childSize: child.bounds.size)

        var requestedOwnSize = child.bounds.size

        if scrollXEnabled {

            requestedOwnSize.height += scrollBarWidths.x
        }

        if scrollYEnabled {

            requestedOwnSize.width += scrollBarWidths.y
        }

        let constrainedSize = constraints.constrain(requestedOwnSize)

        scrollBarLengths.y = constrainedSize.height / (child.bounds.size.height / constrainedSize.height)
        
        scrollBarLengths.x = constrainedSize.width / (child.bounds.size.width / constrainedSize.width)

        if scrollYEnabled {

            scrollBarLengths.x -= scrollBarWidths.y
        }

        return constrainedSize
    }

    private func updateEnabledDimensions(maxOwnSize: DSize2, childSize: DSize2) {

        let previousXEnabled = scrollXEnabled

        let previousYEnabled = scrollYEnabled

        if scrollXEnabled {
        
            scrollYEnabled = maxOwnSize.height - scrollBarWidths.x < childSize.height
        
        } else {

            scrollYEnabled = maxOwnSize.height < childSize.height
        }

        if scrollYEnabled {
            
            scrollXEnabled = maxOwnSize.width - scrollBarWidths.y < childSize.width

        } else {

            scrollXEnabled = maxOwnSize.width < childSize.width
        }

        if previousXEnabled != scrollXEnabled || previousYEnabled != scrollYEnabled {

            updateEnabledDimensions(maxOwnSize: maxOwnSize, childSize: childSize)
        }
    }

    override public func renderContent() -> RenderObject? {

        return RenderObject.Container {

            RenderObject.Clip(globalBounds) {

                RenderObject.Translation(-offsets) {

                    child.render()
                }
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

    public func consume(_ event: GUIMouseEvent) {

        switch event {
        
        case let event as GUIMouseButtonDownEvent:

            if event.button == .Left {

                let localPosition = event.position - globalPosition

                scrollXActive = xScrollBarBounds.contains(point: localPosition)

                scrollYActive = yScrollBarBounds.contains(point: localPosition)

                mouseTrackingStartPosition = event.position
            }

        case let event as GUIMouseButtonUpEvent:

            scrollXActive = false

            scrollYActive = false

            previousScrollProgress = scrollProgress

        case let event as GUIMouseMoveEvent:
            
            let totalMove = event.position - mouseTrackingStartPosition
            
            let scrollProgressBeforeUpdate = scrollProgress

            scrollProgress = previousScrollProgress

            if scrollXActive {

                scrollProgress.x += totalMove.x / maxScrollBarTranslations.x
            }

            if scrollYActive {

                scrollProgress.y += totalMove.y / maxScrollBarTranslations.y
            }

            if scrollProgressBeforeUpdate != scrollProgress {

                invalidateRenderState()
            }

        case let event as GUIMouseWheelEvent:

            if scrollYEnabled {

                scrollProgress.y -= event.scrollAmount.y / 10

            } else if scrollXEnabled {

                scrollProgress.x -= event.scrollAmount.x / 10
            }

            previousScrollProgress = scrollProgress

            invalidateRenderState()

        default:

            break
        }
    }
}