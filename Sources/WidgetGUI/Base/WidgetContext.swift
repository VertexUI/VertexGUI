import VisualAppBase
import GfxMath
import Events

public class WidgetContext {
    public internal(set) var window: Window
    private var _getTextBoundsSize: (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2
    private var _requestCursor: (_ cursor: Cursor) -> () -> Void
    private var _createWindow: (_ guiRootBuilder: @autoclosure () -> Root, _ options: Window.Options) -> Window
    weak public internal(set) var focusedWidget: Widget? {
        didSet {
            if let unregister = unregisterOnFocusChanged {
                unregister()
            }
            if let unregister = unregisterOnFocusDestroyed {
                unregister()
            }
        }
    }
    private var unregisterOnFocusChanged: (() -> ())?
    private var unregisterOnFocusDestroyed: (() -> ())?
    public internal(set) var debugLayout: Bool = false
    private let _getApplicationTime: () -> Double
    public var applicationTime: Double {
        _getApplicationTime()
    }

    private let getRealFps: () -> Double
    public var realFps: Double {
        getRealFps()
    }

    private let _queueLifecycleMethodInvocation: (Widget.LifecycleMethod, Widget, Widget, Widget.LifecycleMethodInvocationReason) -> ()
    
    public let inspectionBus = WidgetBus<WidgetInspectionMessage>()

    public private(set) var onTick = EventHandlerManager<Tick>()

    public init(
        window: Window,
        getTextBoundsSize: @escaping (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2,
        getApplicationTime: @escaping () -> Double,
        getRealFps: @escaping () -> Double,
        createWindow: @escaping (_ guiRootBuilder: @autoclosure () -> Root, _ options: Window.Options) -> Window,
        requestCursor: @escaping (_ cursor: Cursor) -> () -> Void,
        queueLifecycleMethodInvocation: @escaping (Widget.LifecycleMethod, Widget, Widget, Widget.LifecycleMethodInvocationReason) -> ()) {
            self.window = window
            self._getTextBoundsSize = getTextBoundsSize
            self._getApplicationTime = getApplicationTime
            self.getRealFps = getRealFps
            self._createWindow = createWindow
            self._requestCursor = requestCursor
            self._queueLifecycleMethodInvocation = queueLifecycleMethodInvocation
    }

    public func getTextBoundsSize(_ text: String, fontConfig: FontConfig, maxWidth: Double? = nil) -> DSize2 {
        _getTextBoundsSize(text, fontConfig, maxWidth)
    }

    public func requestCursor(_ cursor: Cursor) -> () -> Void {
        _requestCursor(cursor)
    }

    public func createWindow(guiRoot guiRootBuilder: @autoclosure () -> Root, options: Window.Options) -> Window {
        _createWindow(guiRootBuilder(), options)
    }

    // TODO: maybe need an extra focusedWidget context for specific areas / child trees
    public func requestFocus(_ widget: Widget) -> Bool {
        if let previousFocusedWidget = focusedWidget {
            previousFocusedWidget.dropFocus()
        }
        focusedWidget = widget
        focusedWidget!.focused = true
        unregisterOnFocusDestroyed = focusedWidget!.onDestroy { [unowned self] _ in
            if let focusedWidget = focusedWidget, focusedWidget === widget {
                self.focusedWidget = nil
            }
        }
        unregisterOnFocusChanged = focusedWidget!.onFocusChanged { [unowned self] focused in
            if let focusedWidget = focusedWidget {
                if focusedWidget === widget && !focused {
                    self.focusedWidget = nil
                }
            }
        }
        return true
    }

    public func queueLifecycleMethodInvocation(_ method: Widget.LifecycleMethod, target: Widget, sender: Widget, reason: Widget.LifecycleMethodInvocationReason) {
        _queueLifecycleMethodInvocation(method, target, sender, reason)
    }
}
