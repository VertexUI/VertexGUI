import GfxMath
import Events
import Drawing

public class WidgetContext {
    public let getRootSize: () -> DSize2
    private var _requestCursor: (_ cursor: Cursor) -> () -> Void
    private let _getKeyStates: () -> KeyStatesContainer
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
        getRootSize: @escaping () -> DSize2,
        getKeyStates: @escaping () -> KeyStatesContainer,
        getApplicationTime: @escaping () -> Double,
        getRealFps: @escaping () -> Double,
        requestCursor: @escaping (_ cursor: Cursor) -> () -> Void,
        queueLifecycleMethodInvocation: @escaping (Widget.LifecycleMethod, Widget, Widget, Widget.LifecycleMethodInvocationReason) -> (),
        focusManager: FocusManager) {
            self.getRootSize = getRootSize
            self._getKeyStates = getKeyStates
            self._getApplicationTime = getApplicationTime
            self.getRealFps = getRealFps
            self._requestCursor = requestCursor
            self._queueLifecycleMethodInvocation = queueLifecycleMethodInvocation
            self.focusManager = focusManager
    }

    public func requestCursor(_ cursor: Cursor) -> () -> Void {
        _requestCursor(cursor)
    }

    public func queueLifecycleMethodInvocation(_ method: Widget.LifecycleMethod, target: Widget, sender: Widget, reason: Widget.LifecycleMethodInvocationReason) {
        _queueLifecycleMethodInvocation(method, target, sender, reason)
    }
}
