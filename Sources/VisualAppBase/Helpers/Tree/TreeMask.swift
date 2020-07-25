/*
public protocol RenderObjectTreeMaskItem {
    var index: Int { get set }

    typealias SubMask = RenderObjectTreeSubMaskItem
}

public struct RenderObjectTreeSubMaskItem: RenderObjectTreeMaskItem, CustomStringConvertible {
    public var index: Int
    public var items: [RenderObjectTreeMaskItem]

    public var description: String {
        "(\(0), SubMask {\n\(items.map({ "\($0)" }).joined(separator: ";\n"))\n})"
    }

    public init(index: Int, items: [RenderObjectTreeMaskItem]) {
        self.index = index
        self.items = items.sorted { $0.index < $1.index }
    }
}

public struct RenderObjectTreeMaskLeafItem: RenderObjectTreeMaskItem, CustomStringConvertible {
    public var index: Int

    public var description: String {
        "(\(index), Leaf)"
    }

    public init(index: Int) {
        self.index = index
    }
}*/

/*
public enum RenderObjectTreeMaskEntry {
    // TODO: maybe need Empty as well?, however render tree should always have children, so Tree should be used
    case Leaf
    indirect case Tree(_ branches: [(index: Int, mask: RenderObjectTreeMaskEntry)])

    /// - Returns whether any leaf item path equals or contains the given path.
    /// If path length is 0, returns true
    public func containsAny(_ path: TreePath) -> Bool {
        if path.count == 0 {
            return true
        }
        
        switch self {
        case .Leaf:
            return true
        case .Tree(let branches):
            for branch in branches {
                if branch.index == path[0] && branch.mask.containsAny(path.dropFirst(1)) {
                    return true
                }
            }
            return false
        }
        /*
        var checkEntries = items
        outer: for pathSegmentIndex in 0..<path.count {
            for item in checkItems {
                if item.index == path[pathSegmentIndex] {
                    if let item = item as? RenderObjectTreeMaskLeafItem {
                        return true
                    } else if let item = item as? RenderObjectTreeSubMaskItem {
                        if pathSegmentIndex + 1 == path.count {
                            return true
                        } else {
                            checkItems = item.items       
                            continue outer
                        }
                    }
                }
            }
            break
        }
        return false*/
    }

    /*private func addRecursively(_ path: TreePath, _ pathSegmentIndex: Int, _ items: [RenderObjectTreeMaskItem]) -> [RenderObjectTreeMaskItem] {
        var newItems = [RenderObjectTreeMaskItem]()
        var added = false
        for item in items {
            if item.index == path[pathSegmentIndex] {
                added = true
                if let item = item as? RenderObjectTreeMaskLeafItem {
                    if pathSegmentIndex < path.count - 1 {
                        newItems.append(RenderObjectTreeSubMaskItem(index: path[pathSegmentIndex], items: addRecursively(path, pathSegmentIndex + 1, [])))
                    } else {
                        newItems.append(item)
                    }
                } else if let item = item as? RenderObjectTreeSubMaskItem {
                    if pathSegmentIndex < path.count - 1 {
                        newItems.append(RenderObjectTreeSubMaskItem(index: path[pathSegmentIndex], items: addRecursively(path, pathSegmentIndex + 1, item.items)))
                    } else {
                        newItems.append(item)
                    }
                }
            } else {
                newItems.append(item)
            }
        }
        if !added {
            if pathSegmentIndex == path.count - 1 {
                newItems.append(RenderObjectTreeMaskLeafItem(index: path[pathSegmentIndex]))
            } else {
                newItems.append(RenderObjectTreeSubMaskItem(index: path[pathSegmentIndex], items: addRecursively(path, pathSegmentIndex + 1, [])))
            }
        }
        return newItems
    }*/

    /// If the path crosses an item that was a leaf in the mask
    /// (everything under a leaf is masked positively), the leaf is 
    /// converted to a Tree (means, everything that isn't specifically added is not masked positively)
    public func add(_ path: TreePath) -> RenderObjectTreeMask {
        if path.count == 0 {
            return self
        }
        switch self {
        case .Leaf:
            return RenderObjectTreeMaskEntry.Tree([
                (index: path[0], mask: RenderObjectTreeMaskEntry.Leaf.add(path.dropFirst(1)))
            ])
        case .Tree(let branches):
            if let presentBranchIndex = branches.firstIndex { $0.index == path[0] } {
                var newBranches = branches
                newBranches.remove(at: presentBranchIndex)
                let updatedBranchMask = branches[presentBranchIndex].mask.add(path.dropFirst(1))
                newBranches.append((index: path[0], mask: updatedBranchMask))
                return .Tree(newBranches)
            } else {
                return .Tree(branches + [
                    (index: path[0], mask: RenderObjectTreeMaskEntry.Leaf.add(path.dropFirst(1)))
                ])
            }
        }
    }
}

public typealias RenderObjectTreeMask = RenderObjectTreeMaskEntry

/*
// TODO: maybe don't provide a root object that is different from SubMask,
// instead typealias the SubMaskItem to Mask, or have a protocol with default
public struct RenderObjectTreeMask {
    public let items: [RenderObjectTreeMaskItem]

    // TODO: untested
    public var firstPath: TreePath {
        var path = TreePath()
        var checkItems = items
        while checkItems.count > 0 {
            let checkItem = checkItems[0]
            path = path/checkItem.index
            if let checkItem = checkItem as? RenderObjectTreeSubMaskItem {
                checkItems = checkItem.items
            } else {
                break
            }
        }
        return path
    }

    public init(_ items: [RenderObjectTreeMaskItem] = [RenderObjectTreeMaskItem]()) {
        // TODO: sort items by index!
        self.items = items.sorted { $0.index < $1.index }
    }

    /// - Returns whether any leaf item path equals or contains the given path.
    /// If path length is 0, returns true
    public func containsAny(_ path: TreePath) -> Bool {
        if path.count == 0 {
            return true
        }

        var checkItems = items
        outer: for pathSegmentIndex in 0..<path.count {
            for item in checkItems {
                if item.index == path[pathSegmentIndex] {
                    if let item = item as? RenderObjectTreeMaskLeafItem {
                        return true
                    } else if let item = item as? RenderObjectTreeSubMaskItem {
                        if pathSegmentIndex + 1 == path.count {
                            return true
                        } else {
                            checkItems = item.items       
                            continue outer
                        }
                    }
                }
            }
            break
        }
        return false
    }

    private func addRecursively(_ path: TreePath, _ pathSegmentIndex: Int, _ items: [RenderObjectTreeMaskItem]) -> [RenderObjectTreeMaskItem] {
        var newItems = [RenderObjectTreeMaskItem]()
        var added = false
        for item in items {
            if item.index == path[pathSegmentIndex] {
                added = true
                if let item = item as? RenderObjectTreeMaskLeafItem {
                    if pathSegmentIndex < path.count - 1 {
                        newItems.append(RenderObjectTreeSubMaskItem(index: path[pathSegmentIndex], items: addRecursively(path, pathSegmentIndex + 1, [])))
                    } else {
                        newItems.append(item)
                    }
                } else if let item = item as? RenderObjectTreeSubMaskItem {
                    if pathSegmentIndex < path.count - 1 {
                        newItems.append(RenderObjectTreeSubMaskItem(index: path[pathSegmentIndex], items: addRecursively(path, pathSegmentIndex + 1, item.items)))
                    } else {
                        newItems.append(item)
                    }
                }
            } else {
                newItems.append(item)
            }
        }
        if !added {
            if pathSegmentIndex == path.count - 1 {
                newItems.append(RenderObjectTreeMaskLeafItem(index: path[pathSegmentIndex]))
            } else {
                newItems.append(RenderObjectTreeSubMaskItem(index: path[pathSegmentIndex], items: addRecursively(path, pathSegmentIndex + 1, [])))
            }
        }
        return newItems
    }

    public func add(_ path: TreePath) -> RenderObjectTreeMask {
        if path.count == 0 {
            return self
        }
        return RenderObjectTreeMask(addRecursively(path, 0, items))
    }
}*/*/