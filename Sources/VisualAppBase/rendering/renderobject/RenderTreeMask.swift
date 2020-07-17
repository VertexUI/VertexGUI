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
        // TODO: sort items by index
        self.items = items
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
}



public struct RenderTreeMask {
    public var items: [RenderTreeMaskItem]

    public init(_ items: [RenderTreeMaskItem] = [RenderTreeMaskItem]()) {
        // TODO: sort items by index!
        self.items = items
    }

    /// - Returns whether any leaf item path equals or contains the given path.
    public func containsAny(_ path: RenderTreePath) -> Bool {
        if path.count == 0 {
            return true
        }

        var checkItems = items
        var pathSegmentIndex = 0
        // TODO: maybe this can be done with less while true
        outerLoop: while true {
            for item in checkItems {
                if item.index == path[pathSegmentIndex] {
                    if let item = item as? RenderTreeMaskLeafItem {
                        return true
                    } else if let item = item as? RenderTreeSubMaskItem {
                        if pathSegmentIndex + 1 == path.count {
                            return true
                        } else {
                            checkItems = item.items       
                            pathSegmentIndex += 1
                            continue outerLoop
                        }
                    }
                }
            }
            break
        }
        return false
    }

    private func addRecursively(_ path: RenderTreePath, _ pathSegmentIndex: Int, _ items: [RenderTreeMaskItem]) -> [RenderTreeMaskItem] {
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

    public func add(_ path: RenderTreePath) -> RenderTreeMask {
        if path.count == 0 {
            return self
        }
        return RenderTreeMask(addRecursively(path, 0, items))
    }
}