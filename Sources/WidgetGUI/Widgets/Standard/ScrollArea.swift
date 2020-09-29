import CustomGraphicsMath
import VisualAppBase

public class ScrollArea: SingleChildWidget, GUIMouseEventConsumer {

    private let childBuilder: () -> Widget

    
    private let scrollXConfig: ScrollConfig
    
    private let scrollYConfig: ScrollConfig
    
    
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

    private var mouseIsDown = false

    private let mouseMoveBurstLimiter = BurstLimiter(minDelay: 0.005)


    public init(
        scrollX scrollXConfig: ScrollConfig = .Auto,
        scrollY scrollYConfig: ScrollConfig = .Auto,
        @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        
        self.scrollXConfig = scrollXConfig
        self.scrollYConfig = scrollYConfig
        self.childBuilder = childBuilder
    }    

    override public final func buildChild() -> Widget {

        childBuilder()
    }

    override public final func getBoxConfig() -> BoxConfig {

        BoxConfig(preferredSize: child.boxConfig.preferredSize + DSize2(scrollBarWidths.y, scrollBarWidths.x))
    }

    override public final func performLayout(constraints: BoxConstraints) -> DSize2 {

        var childConstraints = BoxConstraints(

            minSize: .zero,
            
            maxSize: .infinity
        )
        
        if !scrollXEnabled {
            
            childConstraints.maxWidth = constraints.maxWidth
            
            if scrollYEnabled {
                
                childConstraints.maxWidth -= scrollBarWidths.y
            }
        }
        
        if !scrollYEnabled {
            
            childConstraints.maxHeight = constraints.maxHeight
            
            if scrollXEnabled {
                
                childConstraints.maxHeight -= scrollBarWidths.x
            }
        }

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

    private final func updateEnabledDimensions(maxOwnSize: DSize2, childSize: DSize2) {

        let previousXEnabled = scrollXEnabled

        let previousYEnabled = scrollYEnabled
        
        if case .Always = scrollXConfig {
            
            scrollXEnabled = true
            
        } else if case .Never = scrollXConfig {
            
            scrollXEnabled = false
        }
        
        if case .Always = scrollYConfig {
            
            scrollYEnabled = true
            
        } else if case .Never = scrollYConfig {
            
            scrollYEnabled = false
        
        } else if case .Auto = scrollYConfig {
            
            if scrollXEnabled {
            
                scrollYEnabled = maxOwnSize.height - scrollBarWidths.x < childSize.height
            
            } else {

                scrollYEnabled = maxOwnSize.height < childSize.height
            }
        }
        
        if case .Auto = scrollXConfig {

            if scrollYEnabled {
                
                scrollXEnabled = maxOwnSize.width - scrollBarWidths.y < childSize.width

            } else {

                scrollXEnabled = maxOwnSize.width < childSize.width
            }
        }

        if previousXEnabled != scrollXEnabled || previousYEnabled != scrollYEnabled {

            updateEnabledDimensions(maxOwnSize: maxOwnSize, childSize: childSize)
        }
    }

    override public final func renderContent() -> RenderObject? {

        return RenderObject.Container {

            // to catch events in spaces where there is no content
            RenderStyleRenderObject(fillColor: .Transparent) {

                RectangleRenderObject(globalBounds)
            }

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

    public final func consume(_ event: GUIMouseEvent) {

        switch event {
        
        case let event as GUIMouseButtonDownEvent:

            if event.button == .Left {

                let localPosition = event.position - globalPosition

                scrollXActive = xScrollBarBounds.contains(point: localPosition)

                scrollYActive = yScrollBarBounds.contains(point: localPosition)

                mouseTrackingStartPosition = event.position

                mouseIsDown = true
            }

        case let event as GUIMouseButtonUpEvent:

            if event.button == .Left {

                scrollXActive = false

                scrollYActive = false

                previousScrollProgress = scrollProgress

                mouseIsDown = false
            }

        case let event as GUIMouseMoveEvent:

            if mouseIsDown {
            
                handleMouseMoveEvent(event)
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

    private final func handleMouseMoveEvent(_ event: GUIMouseMoveEvent) {

        mouseMoveBurstLimiter.limit { [weak self] in

            guard let self = self else {
                
                return
            }

            let totalMove = event.position - self.mouseTrackingStartPosition
            
            let scrollProgressBeforeUpdate = self.scrollProgress

            self.scrollProgress = self.previousScrollProgress

            if self.scrollXActive {

                self.scrollProgress.x += totalMove.x / self.maxScrollBarTranslations.x
            }

            if self.scrollYActive {

                self.scrollProgress.y += totalMove.y / self.maxScrollBarTranslations.y
            }

            if scrollProgressBeforeUpdate != self.scrollProgress {

                self.invalidateRenderState()
            }
        }
    }
}

extension ScrollArea {
    
    public enum ScrollConfig {
        
        case Always, Auto, Never
    }
}
