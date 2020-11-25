import GfxMath

open class RenderObjectContext {

    private let _getTextBoundsSize: (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2
    
    public init(

        getTextBoundsSize: @escaping (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2
    ) {

        self._getTextBoundsSize = getTextBoundsSize
    }

    internal func getTextBoundsSize(_ text: String, fontConfig: FontConfig, maxWidth: Double? = nil) -> DSize2 {

        _getTextBoundsSize(text, fontConfig, maxWidth)
    }
}