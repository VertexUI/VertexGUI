/*
public protocol RenderTreeMaskItem {
    var index: Int { get set }

    typealias SubMask = RenderTreeSubMaskItem
}

public struct RenderTreeSubMaskItem: RenderTreeMaskItem, CustomStringConvertible {
    public var index: Int
    public var items: [RenderTreeMaskItem]

    public var description: String {
        "(\(0), SubMask {\n\(items.map({ "\($0)" }).joined(separator: ";\n"))\n})"
    }

    public init(index: Int, items: [RenderTreeMaskItem]) {
        self.index = index
        self.items = items.sorted { $0.index < $1.index }
    }
}

public struct RenderTreeMaskLeafItem: RenderTreeMaskItem, CustomStringConvertible {
    public var index: Int

    public var description: String {
        "(\(index), Leaf)"
    }

    public init(index: Int) {
        self.index = index
    }
}*/


public enum RenderTreeMaskEntry {
    // TODO: maybe need Empty as well?, however render tree should always have children, so Tree should be used
    case Leaf
    indirect case Tree(_ branches: [(index: Int, mask: RenderTreeMaskEntry)])

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
                    if let item = item as? RenderTreeMaskLeafItem {
                        return true
                    } else if let item = item as? RenderTreeSubMaskItem {
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

    /*private func addRecursively(_ path: TreePath, _ pathSegmentIndex: Int, _ items: [RenderTreeMaskItem]) -> [RenderTreeMaskItem] {
        var newItems = [RenderTreeMaskItem]()
        var added = false
        for item in items {
            if item.index == path[pathSegmentIndex] {
                added = true
                if let item = item as? RenderTreeMaskLeafItem {
                    if pathSegmentIndex < path.count - 1 {
                        newItems.append(RenderTreeSubMaskItem(index: path[pathSegmentIndex], items: addRecursively(path, pathSegmentIndex + 1, [])))
                    } else {
                        newItems.append(item)
                    }
                } else if let item = item as? RenderTreeSubMaskItem {
                    if pathSegmentIndex < path.count - 1 {
                        newItems.append(RenderTreeSubMaskItem(index: path[pathSegmentIndex], items: addRecursively(path, pathSegmentIndex + 1, item.items)))
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
                newItems.append(RenderTreeMaskLeafItem(index: path[pathSegmentIndex]))
            } else {
                newItems.append(RenderTreeSubMaskItem(index: path[pathSegmentIndex], items: addRecursively(path, pathSegmentIndex + 1, [])))
            }
        }
        return newItems
    }*/

    /// If the path crosses an item that was a leaf in the mask
    /// (everything under a leaf is masked positively), the leaf is 
    /// converted to a Tree (means, everything that isn't specifically added is not masked positively)
    public func add(_ path: TreePath) -> RenderTreeMask {
        if path.count == 0 {
            return self
        }
        switch self {
        case .Leaf:
            return RenderTreeMaskEntry.Tree([
                (index: path[0], mask: RenderTreeMaskEntry.Leaf.add(path.dropFirst(1)))
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
                    (index: path[0], mask: RenderTreeMaskEntry.Leaf.add(path.dropFirst(1)))
                ])
            }
        }
    }
}

public typealias RenderTreeMask = RenderTreeMaskEntry

/*
// TODO: maybe don't provide a root object that is different from SubMask,
// instead typealias the SubMaskItem to Mask, or have a protocol with default
public struct RenderTreeMask {
    public let items: [RenderTreeMaskItem]

    // TODO: untested
    public var firstPath: TreePath {
        var path = TreePath()
        var checkItems = items
        while checkItems.count > 0 {
            let checkItem = checkItems[0]
            path = path/checkItem.index
            if let checkItem = checkItem as? RenderTreeSubMaskItem {
                checkItems = checkItem.items
            } else {
                break
            }
        }
        return path
    }

    public init(_ items: [RenderTreeMaskItem] = [RenderTreeMaskItem]()) {
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
                    if let item = item as? RenderTreeMaskLeafItem {
                        return true
                    } else if let item = item as? RenderTreeSubMaskItem {
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

    private func addRecursively(_ path: TreePath, _ pathSegmentIndex: Int, _ items: [RenderTreeMaskItem]) -> [RenderTreeMaskItem] {
        var newItems = [RenderTreeMaskItem]()
        var added = false
        for item in items {
            if item.index == path[pathSegmentIndex] {
                added = true
                if let item = item as? RenderTreeMaskLeafItem {
                    if pathSegmentIndex < path.count - 1 {
                        newItems.append(RenderTreeSubMaskItem(index: path[pathSegmentIndex], items: addRecursively(path, pathSegmentIndex + 1, [])))
                    } else {
                        newItems.append(item)
                    }
                } else if let item = item as? RenderTreeSubMaskItem {
                    if pathSegmentIndex < path.count - 1 {
                        newItems.append(RenderTreeSubMaskItem(index: path[pathSegmentIndex], items: addRecursively(path, pathSegmentIndex + 1, item.items)))
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
                newItems.append(RenderTreeMaskLeafItem(index: path[pathSegmentIndex]))
            } else {
                newItems.append(RenderTreeSubMaskItem(index: path[pathSegmentIndex], items: addRecursively(path, pathSegmentIndex + 1, [])))
            }
        }
        return newItems
    }

    public func add(_ path: TreePath) -> RenderTreeMask {
        if path.count == 0 {
            return self
        }
        return RenderTreeMask(addRecursively(path, 0, items))
    }
}*/