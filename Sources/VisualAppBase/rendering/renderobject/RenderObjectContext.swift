import CustomGraphicsMath

open class RenderObjectContext {

    private var _getTextBoundsSize: (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2
    
    public init(

        getTextBoundsSize: @escaping (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2
    ) {

        self._getTextBoundsSize = getTextBoundsSize
    }

    public func getTextBoundsSize(_ text: String, fontConfig: FontConfig, maxWidth: Double? = nil) -> DSize2 {

        _getTextBoundsSize(text, fontConfig, maxWidth)
    }
}