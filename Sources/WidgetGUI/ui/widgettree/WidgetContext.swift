import VisualAppBase
import CustomGraphicsMath

public class WidgetContext {
    // TODO: implement, e.g. have some way to get text size (bounds)
    public var defaultFontFamily: FontFamily
    public var _getTextBoundsSize: (_ text: String, _ config: TextConfig, _ maxWidth: Double?) -> DSize2

    public init(defaultFontFamily: FontFamily, getTextBoundsSize: @escaping (_ text: String, _ config: TextConfig, _ maxWidth: Double?) -> DSize2) {
        self.defaultFontFamily = defaultFontFamily
        self._getTextBoundsSize = getTextBoundsSize
    }

    public func getTextBoundsSize(_ text: String, config: TextConfig, maxWidth: Double?) -> DSize2 {
        _getTextBoundsSize(text, config, maxWidth)
    }
}