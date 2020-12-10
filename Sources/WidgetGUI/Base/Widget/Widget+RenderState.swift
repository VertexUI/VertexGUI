import VisualAppBase

extension Widget {
    public struct RenderState {
        public var invalid: Bool = true
        // all contents wrapped inside an identifiable object
        public var content: RenderObject.IdentifiedSubTree?        
        // the representation of the Widget
        public var mainContent: RenderObject?
        // additional debug renderings
        public var debuggingContent: [RenderObject] = []
    }
}