public struct TreeRange: Hashable {
    public var start: TreePath 
    public var end: TreePath

    public init(from start: TreePath, to end: TreePath) {
        self.start = start
        self.end = end
    }

    public init() {
        self.start = TreePath()
        self.end = TreePath()
    }

    public func contains(_ path: TreePath) -> Bool {
        var maxCompareCount = min(path.count, start.count)
        for i in 0..<maxCompareCount {
            if path[i] > start[i] {
                break
            } else if path[i] < start[i] {
                return false
            }/* else if path[i] == start[i] && i == maxCompareCount - 1 && path.count > start.count {
                return false
            }*/
        }
        maxCompareCount = min(path.count, end.count)
        for i in 0..<maxCompareCount {
            if path[i] < end[i] {
                break
            } else if path[i] > end[i] {
                return false
            }/* else if path[i] == start[i] && i == maxCompareCount - 1 && path.count > end.count {
                return false
            }*/
        }
        return true
    }

    /*public mutating func add(_ path: TreePath) {

    }*/
    // TODO: implement merging with TreeRangeSet
    /*public func merged(_ other: TreeRange) {
        var result = self
        if other.start < self.start {
            result.start = other.start
        }
        if other.end > self.end {
            result.end = other.end
        }
        return result
    }*/
    public mutating func extend(with path: TreePath) {
        if path < start {
            self.start = path
        }
        if path > end {
            self.end = path
        }
    }

    public func extended(with path: TreePath) -> Self {
        var result = self
        result.extend(with: path)
        return result
    }
}