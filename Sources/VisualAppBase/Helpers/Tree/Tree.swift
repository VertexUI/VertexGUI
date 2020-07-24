/*public protocol TreeNode {


}

public protocol BranchingTreeNode: TreeNode {
    associatedtype Node: TreeNode
    var children: [Node] { get set }
}

public protocol Tree: BranchingTreeNode {
    associatedtype BranchingNode: BranchingTreeNode
}

public struct AnyTree<Node: TreeNode>: Tree {
    public typealias Child = Node
    public var children: [Node]
}*/