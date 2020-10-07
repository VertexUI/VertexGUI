import CustomGraphicsMath

extension RenderObjectTree {
    
    open class Context {

        internal let rootwardBus = RenderObjectTree.Bus<RenderObjectTree.RootwardMessage>()
        
        internal let leafwardBus = RenderObjectTree.Bus<RenderObjectTree.LeafwardMessage>()

        public init() {}
    }
}