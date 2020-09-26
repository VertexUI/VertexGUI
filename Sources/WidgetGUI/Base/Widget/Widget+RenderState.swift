import VisualAppBase

extension Widget {

    public struct RenderState {

        public var invalid: Bool = true

        public var content: RenderObject.IdentifiedSubTree?        
    }
}