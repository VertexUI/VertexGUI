import VisualAppBase
import CustomGraphicsMath

public class WidgetContext {
    public internal(set) var window: Window
    private var _getTextBoundsSize: (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2
    private var _requestCursor: (_ cursor: Cursor) -> () -> Void

    public init(
        window: Window,
        getTextBoundsSize: @escaping (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2,
        requestCursor: @escaping (_ cursor: Cursor) -> () -> Void) {
            self.window = window
            self._getTextBoundsSize = getTextBoundsSize
            self._requestCursor = requestCursor
    }

    public func getTextBoundsSize(_ text: String, fontConfig: FontConfig, maxWidth: Double? = nil) -> DSize2 {
        _getTextBoundsSize(text, fontConfig, maxWidth)
    }

    public func requestCursor(_ cursor: Cursor) -> () -> Void {
        return _requestCursor(cursor)
    }
}