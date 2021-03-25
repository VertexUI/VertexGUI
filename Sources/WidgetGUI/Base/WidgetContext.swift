import VisualAppBase
import GfxMath
import Events
import Drawing

public class WidgetContext {
    public internal(set) var window: Window
    private var _measureText: (_ text: String, _ paint: TextPaint) -> DSize2
    private var _requestCursor: (_ cursor: Cursor) -> () -> Void
    private let _getKeyStates: () -> KeyStatesContainer
    private var _createWindow: (_ guiRootBuilder: @autoclosure () -> Root, _ options: Window.Options) -> Window
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

    public var keyStates: KeyStatesContainer {
        _getKeyStates()
    }

    public let focusManager: FocusManager

    public init(
        window: Window,
        measureText: @escaping (_ text: String, _ paint: TextPaint) -> DSize2,
        getKeyStates: @escaping () -> KeyStatesContainer,
        getApplicationTime: @escaping () -> Double,
        getRealFps: @escaping () -> Double,
        createWindow: @escaping (_ guiRootBuilder: @autoclosure () -> Root, _ options: Window.Options) -> Window,
        requestCursor: @escaping (_ cursor: Cursor) -> () -> Void,
        queueLifecycleMethodInvocation: @escaping (Widget.LifecycleMethod, Widget, Widget, Widget.LifecycleMethodInvocationReason) -> (),
        focusManager: FocusManager) {
            self.window = window
            self._measureText = measureText
            self._getKeyStates = getKeyStates
            self._getApplicationTime = getApplicationTime
            self.getRealFps = getRealFps
            self._createWindow = createWindow
            self._requestCursor = requestCursor
            self._queueLifecycleMethodInvocation = queueLifecycleMethodInvocation
            self.focusManager = focusManager
    }

    public func measureText(text: String, paint: TextPaint) -> DSize2 {
        _measureText(text, paint)
    }

    public func requestCursor(_ cursor: Cursor) -> () -> Void {
        _requestCursor(cursor)
    }

    public func createWindow(guiRoot guiRootBuilder: @autoclosure () -> Root, options: Window.Options) -> Window {
        _createWindow(guiRootBuilder(), options)
    }

    public func queueLifecycleMethodInvocation(_ method: Widget.LifecycleMethod, target: Widget, sender: Widget, reason: Widget.LifecycleMethodInvocationReason) {
        _queueLifecycleMethodInvocation(method, target, sender, reason)
    }
}
