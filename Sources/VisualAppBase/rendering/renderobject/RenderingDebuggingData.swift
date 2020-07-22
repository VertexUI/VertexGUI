public struct RenderingDebuggingData {
    public var tree: RenderTree
    public var groups: [RenderGroup]

    public init(tree: RenderTree, groups: [RenderGroup]) {
        self.tree = tree
        self.groups = groups
    }
}