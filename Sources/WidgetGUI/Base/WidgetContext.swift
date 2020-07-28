import VisualAppBase
import CustomGraphicsMath

public class WidgetContext {
    // TODO: implement, e.g. have some way to get text size (bounds)
    public var defaultFontFamily: FontFamily
    private var _getTextBoundsSize: (_ text: String, _ config: TextConfig, _ maxWidth: Double?) -> DSize2
    private var _requestCursor: (_ cursor: Cursor) -> () -> Void

    public init(
        defaultFontFamily: FontFamily,
        getTextBoundsSize: @escaping (_ text: String, _ config: TextConfig, _ maxWidth: Double?) -> DSize2,
        requestCursor: @escaping (_ cursor: Cursor) -> () -> Void) {
        self.defaultFontFamily = defaultFontFamily
        self._getTextBoundsSize = getTextBoundsSize
        self._requestCursor = requestCursor
    }

    public func getTextBoundsSize(_ text: String, config: TextConfig, maxWidth: Double?) -> DSize2 {
        _getTextBoundsSize(text, config, maxWidth)
    }

    public func requestCursor(_ cursor: Cursor) -> () -> Void {
        return _requestCursor(cursor)
    }
}