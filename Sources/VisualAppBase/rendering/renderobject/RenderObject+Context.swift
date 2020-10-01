import CustomGraphicsMath

extension RenderObject {
    
    open class Context {

        internal let rootwardBus = RenderObjectTree.Bus<RenderObjectTree.RootwardMessage>()
        
        internal let leafwardBus = RenderObjectTree.Bus<RenderObjectTree.LeafwardMessage>()

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
}