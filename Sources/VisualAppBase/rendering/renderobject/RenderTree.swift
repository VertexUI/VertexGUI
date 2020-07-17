// TODO: maybe name RenderObjectTree
public struct RenderTree {
    public var children: [RenderObject]

    public init(_ children: [RenderObject]) {
        self.children = children
    }

    /*public subscript(path: RenderTreePath) -> RenderObject? {

    }*/
}