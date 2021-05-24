public protocol TreeNode {
    associatedtype Child: TreeNode
    var children: [Child] { get }
    var isBranching: Bool { get }
}

public extension TreeNode {
    var isBranching: Bool {
        false
    }
}

/*
public protocol ProtoTreeNodeImpl: TreeNode {
}

public struct ImplTreeNode: ProtoTreeNodeImpl where Child: ProtoTreeNodeImpl {
    public var children: [Child]
    public var isBranching: Bool { false }
}

public struct ImplTreeNode2: ProtoTreeNodeImpl {
    public var children: [Child]
    public var isBranching: Bool { false }

    public init() {
        self.children = []
        self.children.append(ImplTreeNode())
    }
    
}
*/
/*public protocol TreeNode {
}


public protocol LeafTreeNode: TreeNode {
}

public extension LeafTreeNode {
}

public protocol BranchingTreeNodeMarker: TreeNode {

}

public protocol BranchingTreeNode: BranchingTreeNodeMarker {
    associatedtype Child: TreeNode
    var children: [Child] { get set }

    func otherBranches() -> [Child]
}

public extension BranchingTreeNode {
    func otherBranches() -> [Child] {
        var result = [Child]()
        for child in children {
            if child is BranchingTreeNodeMarker {
                result.append(child)
            }
        }
        return result
    }
}*/
/*

public class CoolTreeNodeTest: TreeNode {
    public var children: [CoolTreeNodeTest] = []
}

public class CoolLeafNodeTest: CoolTreeNodeTest, LeafTreeNode {
    
}*/

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
