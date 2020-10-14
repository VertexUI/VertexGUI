import VisualAppBase
import CustomGraphicsMath

public class WidgetContext {
    public internal(set) var window: Window
    private var _getTextBoundsSize: (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2
    private var _requestCursor: (_ cursor: Cursor) -> () -> Void
    public internal(set) var focus: Widget?
    private var unregisterOnFocusChanged: (() -> ())?
    public internal(set) var debugLayout: Bool = false
    private let _getApplicationTime: () -> Double
    public var applicationTime: Double {
        _getApplicationTime()
    }

    public init(
        window: Window,
        getTextBoundsSize: @escaping (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2,
        getApplicationTime: @escaping () -> Double,
        requestCursor: @escaping (_ cursor: Cursor) -> () -> Void) {
            self.window = window
            self._getTextBoundsSize = getTextBoundsSize
            self._getApplicationTime = getApplicationTime
            self._requestCursor = requestCursor
    }

    public func getTextBoundsSize(_ text: String, fontConfig: FontConfig, maxWidth: Double? = nil) -> DSize2 {
        _getTextBoundsSize(text, fontConfig, maxWidth)
    }

    public func requestCursor(_ cursor: Cursor) -> () -> Void {
        return _requestCursor(cursor)
    }

    // TODO: maybe need an extra focus context for specific areas / child trees
    public func requestFocus(_ widget: Widget) -> Bool {
        if let oldFocus = focus {
            oldFocus.dropFocus()
        }
        focus = widget
        unregisterOnFocusChanged = focus!.onFocusChanged { [unowned self] _ in
            if !focus!.focused {
                focus = nil
                if let unregister = unregisterOnFocusChanged {
                    unregister()
                }
            }
        }
        return true
    }
}