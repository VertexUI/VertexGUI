public struct TreeRange {
    public var start: RenderTreePath 
    public var end: RenderTreePath

    public init(from start: RenderTreePath, to end: RenderTreePath) {
        self.start = start
        self.end = end
    }

    public func contains(_ path: RenderTreePath) -> Bool {
        var maxCompareCount = min(path.count, start.count)
        for i in 0..<maxCompareCount {
            if path[i] > start[i] {
                break
            } else if path[i] < start[i] {
                return false
            } else if path[i] == start[i] && i == maxCompareCount - 1 && path.count > start.count {
                return false
            }
        }
        maxCompareCount = min(path.count, end.count)
        for i in 0..<maxCompareCount {
            if path[i] < end[i] {
                break
            } else if path[i] > end[i] {
                return false
            } else if path[i] == start[i] && i == maxCompareCount - 1 && path.count > end.count {
                return false
            }
        }
        return true
    }
}