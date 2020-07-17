import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

/*
struct DPoint2 {
    var x: Int
    var y: Int
}

extension DPoint2 {
    init(_ x: Int, _ y: Int) {
        self.init(x: x, y: y)
    }
}

struct DSize2 {
    var width: Int
    var height: Int
}

extension DSize2 {
    init(_ width: Int, _ height: Int) {
        self.init(width: width, height: height)
    }
}

protocol Widget {
    associatedtype State: WidgetState
    func render (state: State, renderer: SDLRenderer) throws
}

protocol WidgetState {
    var position: DPoint2 { get set }
    var size: DSize2 { get set }
}*/


// TODO: maybe create a rendercacheable protocol? And a widget tree renderer?
// TODO: maybe rendering should be done by iterating the tree instead of recursive calls --> better optimization?
open class Widget: Bounded, Parent, Child {
    open var id: UInt = UInt.random(in: 0..<UInt.max)

    open var _context: WidgetContext?
    open var context: WidgetContext? {
        // TODO: might cache _context
        get {
            if let context = _context {
                return context
            }
            if let parent = parent as? Widget {
                return parent.context
            }
            return nil
        }
        set {
            _context = newValue
        }
    }

    open var constraints: BoxConstraints? = nil

    public var onParentChanged = EventHandlerManager<Parent?>()
    public var onAnyParentChanged = EventHandlerManager<Parent?>()
    public var onRenderStateInvalidated = EventHandlerManager<Widget>()
    private var unregisterAnyParentChangedHandler: EventHandlerManager<Parent?>.UnregisterCallback?
    weak open var parent: Parent? = nil {
        willSet {
            // TODO: remove listeners on any parent when parent is removed
            if newValue == nil && unregisterAnyParentChangedHandler != nil {
                unregisterAnyParentChangedHandler!()
            }
        }

        didSet {
            try! onParentChanged.invokeHandlers(parent)
            try! onAnyParentChanged.invokeHandlers(parent)
            if parent != nil {
                if let childParent = parent as? Child {
                    unregisterAnyParentChangedHandler = childParent.onAnyParentChanged({
                        try! self.onAnyParentChanged.invokeHandlers($0)
                    })
                }
            }
        }
    }

    //open var size: DSize2 = DSize2(0, 0)
    //open var position: DPoint2 = DPoint2(0,0)
    
    // TODO: might need to create something like layoutBounds and renderBounds (area that is invalidated on rerender request --> could be more than layoutBounds and affect outside widgets (e.g. a drop shadow that is not included in layoutBounds))
    open var bounds: DRect = DRect(topLeft: DPoint2(0,0), size: DSize2(0,0)) {
        didSet {
            // TODO: maybe let the parent list for onUpdateBounds on it's children instead of calling the parent
            if oldValue != bounds {
                if let parent = self.parent {
                    try! parent.relayout()
                }
            }
        }
    }

    open var globalBounds: DRect {
        get {
            return DRect(topLeft: globalPosition, size: bounds.size)
        }
    }
    
    open var globalPosition: DPoint2 {
        get {
            if parent != nil {
                return parent!.globalPosition + bounds.topLeft
            }
            return bounds.topLeft
        }
    }

    /*open var globalContext: Context? = nil {
        didSet {
            children.forEach { $0.globalContext = globalContext }
        }
    }  */

   // public var onParentChanged = EventHandlerManager<Parent?>()
    //public var onAnyParentChanged = EventHandlerManager<Parent?>()

    /*open var mouseEventConsumers: [MouseEventConsumer] {
        get {
            // TODO: implement mouse events!!
            return [] // children
        }

        set {
            print("ERROR??, Cant set mouseEventConsumers on Widget")
        }
    }
*/
    public init() {}

    // TODO: rename fromChild parameter to something more generic / or use relayout or something like that, probably only needed in widgets that have children --> in these avoid relayout the child that has triggered the parent relayout
    open func layout(fromChild: Bool) throws {
        fatalError("layout() not implemented.")
    }

    public func layout() throws {
        try layout(fromChild: false)
    }

    open func relayout() throws {
        try layout(fromChild: true)
    }

    /*open func consume(_ event: GUIMouseEvent) throws {
        try provideMouseEvent(event)
    }*/

    open func findParent(_ condition: (_ parent: Parent) throws -> Bool) rethrows -> Parent? {
        var parent: Parent? = self.parent
        while parent != nil {
            if try condition(parent!) {
                return parent
            }
            if let currentParent = parent as? Widget {
                parent = currentParent.parent
            }
        } 
        return nil
    }

    open func parentOfType<T>(_ type: T.Type) -> T? {
        var parent: Parent? = self.parent
        while parent != nil {
            if let parent = parent! as? T {
                return parent
            }
            if let currentParent = parent! as? Child {
                parent = currentParent.parent
            } else {
                break
            }
        }
        return nil
    }

    /// This should trigger a rerender of the widget in the next frame.
    public func invalidateRenderState(_ widget: Widget?) {
        let widget = widget ?? self
        try! onRenderStateInvalidated.invokeHandlers(widget)
    }

    open func render() -> RenderObject? {
        fatalError("render() not implemented.")
    }
}

