import VisualAppBase
import CustomGraphicsMath
import Dispatch

open class Root: Parent {

    open var widgetContext: WidgetContext? {

        didSet {
            
            if let widgetContext = widgetContext {

                widgetContext.debugLayout = debugLayout
            }

            rootWidget.context = widgetContext
        }
    }
    
    open var renderObjectContext: RenderObjectContext? {

        didSet {

            if let renderObjectContext = renderObjectContext {

                renderObjectTree.context = renderObjectContext
            }
        }
    }

    open var bounds: DRect = DRect(min: DPoint2(0,0), size: DSize2(0,0)) {

        didSet {

            rootWidget.invalidateRenderState()

            layout()

            updateRenderObjectTree()
        }
    }

    open var globalPosition: DPoint2 {

        get {

            return bounds.min
        }
    }

    public var rootWidget: Widget

    private var renderObjectTreeRenderer: RenderObjectTreeRenderer
    
    internal var renderObjectTree: RenderObjectTree

    private var rerenderWidgets: [Widget] = []
    
    private var mouseEventManager = WidgetTreeMouseEventManager()

    public var debugLayout = false {

        didSet {

            if let widgetContext = widgetContext {

                widgetContext.debugLayout = debugLayout
            }
        }
    }

    public var onDebuggingDataAvailable = ThrowingEventHandlerManager<RenderObjectTreeRenderer.DebuggingData>()

    public init(rootWidget contentRootWidget: Widget) {

        rootWidget = contentRootWidget
        
        renderObjectTree = RenderObjectTree()
        
        renderObjectTreeRenderer = RenderObjectTreeRenderer(renderObjectTree)
        
        rootWidget.mount(parent: self)

        /*_ = rootWidget.onRenderStateInvalidated { [unowned self] in

            updateRenderObjectTree($0)
        }*/

        _ = rootWidget.onBoxConfigChanged { [unowned self] _ in

            layout()
        }

        _ = rootWidget.onAnyRenderStateInvalidated { [unowned self] in

            rerenderWidgets.append($0)
        }
    }

    open func layout() {

        rootWidget.layout(constraints: BoxConstraints(minSize: bounds.size, maxSize: bounds.size))
    }

    @discardableResult open func consume(_ rawMouseEvent: RawMouseEvent) -> Bool {

        //_ = self.mouseEventManager.propagate(event: rawMouseEvent, through: self.rootWidget)

        propagate(rawMouseEvent)

        return false
    }

    @discardableResult open func consume(_ rawKeyEvent: KeyEvent) -> Bool {
        
        propagate(rawKeyEvent)

        return false
    }

    @discardableResult open func consume(_ rawTextEvent: TextEvent) -> Bool {

        propagate(rawTextEvent)

        return false
    }

    /// - Parameter widget: If a specific widget is passed only the sub tree that was created by the widget will be updated.
    open func updateRenderObjectTree(_ widget: Widget? = nil) {

        if renderObjectTree.children.count == 0 {

            // TODO: provide an insert function
            renderObjectTree.children.append(rootWidget.render())

            if let context = renderObjectContext {
                
                renderObjectTree.context = context
            }

            renderObjectTreeRenderer.refresh()

        } else {

            var updatedWidget = widget ?? rootWidget

            var updatedSubTree = updatedWidget.render()

            if let update = renderObjectTree.replace(updatedSubTree) {

                renderObjectTreeRenderer.processUpdate(update)
            }
        }

        if let context = renderObjectContext {
                
            renderObjectTree.context = context
        }



        try! onDebuggingDataAvailable.invokeHandlers(renderObjectTreeRenderer.debuggingData)
    }

    // TODO: maybe this little piece of rendering logic belongs into the App as well? / Maybe return a render object tree as well???? 
    // TODO: --> A Game scene could also be a render object with custom logic which is redrawn on every frame by render strategy.
    open func render(with renderer: Renderer) {
        
        for widget in rerenderWidgets {
            
            widget.updateRenderState()
        }

        if let context = renderObjectContext {
                
            renderObjectTree.context = context
        }



        rerenderWidgets = []

        try! renderObjectTreeRenderer.render(with: renderer, in: bounds)
    }



    /*
    Event Propagation
    --------------------
    */
    internal var previousMouseEventTargets: [ObjectIdentifier: [Widget & GUIMouseEventConsumer]] = [

        ObjectIdentifier(GUIMouseButtonDownEvent.self): []
    ]

    internal func propagate(_ event: RawMouseEvent) {

        switch event {

        case _ as RawMouseButtonDownEvent:

            previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)] = []

        case let event as RawMouseButtonUpEvent:

            for previousDownEventTarget in previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)]! {
                
                // TODO: need to calculate point translation here as well for the previous targets

                previousDownEventTarget.consume(GUIMouseButtonUpEvent(button: event.button, position: event.position))
            }
        
        default:
        
            break
        }

        let renderObjectsAtPoint = self.renderObjectTree.objectsAt(point: event.position)

        for renderObjectAtPoint in renderObjectsAtPoint {

            if let object = renderObjectAtPoint.object as? IdentifiedSubTreeRenderObject {

               // print("Mouse Event On Identified RenderObject with id", object.id)
     
                if let widget = rootWidget.getChild { $0.id == object.id } {

                    //print("WOW got a widget", widget, event)
                    if let widget = widget as? GUIMouseEventConsumer & Widget {

                        print("WOW GOT A MOUSE CONSUMER WIDGET!!!!", widget)
                        switch event {
                        
                        case let event as RawMouseButtonDownEvent:

                            widget.consume(GUIMouseButtonDownEvent(button: event.button, position: renderObjectAtPoint.transformedPoint))

                            previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)]!.append(widget)

                        case let event as RawMouseButtonUpEvent:

                            var wasPreviousTarget = false

                            for previousTarget in previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)]! {

                                if previousTarget.mounted && previousTarget === widget {

                                    previousTarget.consume(GUIMouseButtonClickEvent(button: event.button, position: renderObjectAtPoint.transformedPoint))

                                    wasPreviousTarget = true
                                }
                            }

                            if !wasPreviousTarget {

                                widget.consume(GUIMouseButtonUpEvent(button: event.button, position: renderObjectAtPoint.transformedPoint))
                            }

                        case let event as RawMouseMoveEvent:

                            let pointTransformation = renderObjectAtPoint.transformedPoint - event.position

                            widget.consume(GUIMouseMoveEvent(position: renderObjectAtPoint.transformedPoint, previousPosition: event.previousPosition + pointTransformation))

                        default:

                            print("Unsupported event.")
                        }
                     
                        // TODO: implement click

                        //widget.consume(GUIMouseButtonClickEvent(button: .Left, position: renderObjectAtPoint.transformedPoint))
                    }
                }
            }
        }
    }

    internal func propagate(_ rawKeyEvent: KeyEvent) {

        if let focus = widgetContext?.focus as? GUIKeyEventConsumer {

            if let keyDownEvent = rawKeyEvent as? KeyDownEvent {

                focus.consume(

                    GUIKeyDownEvent(

                        key: keyDownEvent.key,

                        keyStates: keyDownEvent.keyStates,

                        repetition: keyDownEvent.repetition))

            } else if let keyUpEvent = rawKeyEvent as? KeyUpEvent {

                focus.consume(

                    GUIKeyUpEvent(

                        key: keyUpEvent.key,

                        keyStates: keyUpEvent.keyStates,

                        repetition: keyUpEvent.repetition))

            } else {

                fatalError("Unsupported event type: \(rawKeyEvent)")
            }
        }
    }

    internal func propagate(_ event: TextEvent) {

        if let focused = widgetContext?.focus as? GUITextEventConsumer {

            if let event = event as? TextInputEvent {

                focused.consume(GUITextInputEvent(event.text))
            }
        }
    }
    /*
    End Event Propagation
    ----------------------
    */

    open func destroy() {

        rootWidget.destroy()
    }
}