import VisualAppBase
import GL
import CustomGraphicsMath
import Path
import Foundation

fileprivate protocol RenderGroup {
    var id: Int { get }
    //var renderTreeMask: RenderTreeMask { get set }
    var treeRange: TreeRange? { get set }

    mutating func add(_ path: TreePath)
}

fileprivate extension RenderGroup {
    mutating func add(_ path: TreePath) {
        if var treeRange = treeRange {
            treeRange.extend(with: path)
            self.treeRange = treeRange
        } else {
            self.treeRange = TreeRange(from: path, to: path)
        }
    }
}

fileprivate struct UncachableRenderGroup: RenderGroup {
    public var id: Int
    public var treeRange: TreeRange? = nil

    public init(id: Int) {
        self.id = id
    }
}

fileprivate struct CachableRenderGroup: RenderGroup {
    public var id: Int
    var treeRange: TreeRange? = nil
    public var cache: VirtualScreen?
    public var cacheInvalidated = false

    public init(id: Int) {
        self.id = id
    }
}

// TODO: give rendering an extra package outside of VisualAppBase
// TODO: maybe rename to RenderTreeRenderer?
// TODO: maybe have a RenderTreeGroupGenerator with efficientUpdate(identified: ...) etc. + a group renderer?
// TODO: create a RenderState --> contains RenderTree, Transitions and more depending on RenderStrategy, maybe
public class RenderTreeRenderer {
    private var renderTree: RenderTree?
    // TODO: maybe define this as a RenderState object?
    private var renderGroups = [RenderGroup]()
    private var _nextRenderGroupId = 0
    private var nextRenderGroupId: Int {
        get {
            defer { _nextRenderGroupId += 1 }
            return _nextRenderGroupId
        }
    }
    private var availableCaches = [VirtualScreen]()
    
    public init() {
    }

    public func setRenderTree(_ updatedRenderTree: RenderTree) {
        self.renderTree = updatedRenderTree
        generateRenderGroups()
    }

    // the only update groups etc. for the really updated parts
    // TODO: modify this and provide a function --> process RenderTreeUpdate which contains the update info tuple
    public func updateRenderTree(_ identifiedSubTree: IdentifiedSubTreeRenderObject) {
        //print("UPDATE RENDER TREE", renderTree!.idPaths)
        // TODO: tree comparison
        let (updatedRenderTree, updatedSubTreePath) = renderTree!.updated(identifiedSubTree)
        var updatedRenderObjectTypePaths = [updatedSubTreePath]
        renderTree = updatedRenderTree
        print("TREE UPDATE", updatedSubTreePath)

        var updatedTypeGroupIndices = Set<Int>()
        for i in 0..<renderGroups.count {
            if let treeRange = renderGroups[i].treeRange {
                if var group = renderGroups[i] as? CachableRenderGroup {
                    if treeRange.contains(updatedSubTreePath) {
                        group.cacheInvalidated = true
                        renderGroups[i] = group
                    }
                }
                
                for updatedTypePath in updatedRenderObjectTypePaths {
                    if treeRange.contains(updatedTypePath) {
                        updatedTypeGroupIndices.insert(i)
                        if var group = renderGroups[i] as? CachableRenderGroup, let cache = group.cache {
                           group.cache = nil
                           renderGroups[i] = group
                           availableCaches.append(cache) 
                        }
                    }
                }
            }
        }

        // TODO: maybe rename to updateRequiringGroupBatches
        var groupUpdateBatches: [[Int]] = [[Int]()]
        for i in updatedTypeGroupIndices.sorted() {
            if let last = groupUpdateBatches[groupUpdateBatches.count - 1].last {
                if last + 1 < i {
                    groupUpdateBatches.append([i])
                } else {
                    groupUpdateBatches[groupUpdateBatches.count - 1].append(i)
                }
            } else {
                groupUpdateBatches[groupUpdateBatches.count - 1].append(i)
            }
        }
        let groupUpdateBatchRanges: [TreeRange?] = groupUpdateBatches.map {
            var compoundStart: TreePath?
            var compoundEnd: TreePath?
            for i in $0 {
                if compoundStart == nil {
                    if let groupRangeStart = renderGroups[i].treeRange?.start {
                        compoundStart = groupRangeStart 
                    }
                }
                if let groupRangeEnd = renderGroups[i].treeRange?.end {
                    compoundEnd = groupRangeEnd
                }
            }
            if let compoundStart = compoundStart, let compoundEnd = compoundEnd {
                return TreeRange(from: compoundStart, to: compoundEnd)
            }
            
            return nil
        }
        print("UPDATE BATCHES", groupUpdateBatches)
        print("UPDATE RANGES", groupUpdateBatchRanges)

        var updatedRenderGroups = [RenderGroup]()
        for i in 0..<groupUpdateBatchRanges.count {
            let batchGroupIndices = groupUpdateBatches[i]
            guard let batchRange = groupUpdateBatchRanges[i] else {
                continue
            }

            var newRenderGroups = generateRenderGroupsRecursively(for: renderTree!, at: TreePath(), in: batchRange)
            for i in 0..<newRenderGroups.count {
                if var newGroup = newRenderGroups[i] as? CachableRenderGroup {
                    newGroup.cacheInvalidated = true
                    newRenderGroups[i] = newGroup
                }
            }

            let precedingReusableRenderGroups: [RenderGroup]
            if i == 0 {
                if let firstBatchGroupIndex = batchGroupIndices.first, firstBatchGroupIndex > 0 {
                    precedingReusableRenderGroups = Array(renderGroups[0..<firstBatchGroupIndex])
                } else {
                    precedingReusableRenderGroups = []
                }
            } else {
                let precedingBatchGroupIndices = groupUpdateBatches[i - 1]
                let precedingEndIndex = precedingBatchGroupIndices.last!
                let currentStartIndex = batchGroupIndices.first!
                precedingReusableRenderGroups = Array(renderGroups[precedingEndIndex + 1..<currentStartIndex])
            }
            updatedRenderGroups.append(contentsOf: precedingReusableRenderGroups)
            updatedRenderGroups.append(contentsOf: newRenderGroups)
        }
        if let lastBatch = groupUpdateBatches.last, let lastUpdatedGroupIndex = lastBatch.last {
            updatedRenderGroups.append(contentsOf: Array(renderGroups[lastUpdatedGroupIndex...]))
        }
        print("GENERATED UPDATED RENDER GROUPS", updatedRenderGroups)

        renderGroups = updatedRenderGroups
    }

    /*
    Unfinished iterative definition
    private func generateRenderGroups(for mask: RenderTreeMask? = nil) -> [RenderGroup] {
        var groups: [RenderGroup] = [CachableRenderGroup(id: nextRenderGroupId)]

        var currentPath = TreePath([0])
        var parents: [SubTreeRenderObject] = [.Container(renderTree!.children)]
        //var checkObjects = renderTree!.children
        while parents.count > 0 {
            for i in 0..<parents.last!.children.count {
                let object = parents.last!.children[i]
                let objectPath = currentPath/i

                if mask == nil || mask!.containsAny(objectPath) {
                    if object.hasTimedRenderValue || object is RenderObject.Uncachable {
                        if !(groups.last! is UncachableRenderGroup) {
                            groups.append(UncachableRenderGroup(id: nextRenderGroupId))
                        }

                        groups[groups.count - 1].renderTreeMask = groups.last!.renderTreeMask.add(objectPath)
                    } else if let object = object as? RenderObject.CacheSplit {
                        groups.append(CachableRenderGroup(id: nextRenderGroupId))

                        parents.append(object)
                        currentPath = objectPath
                    } else {
                        // TODO: implement
                        if let object = object as? SubTreeRenderObject {

                        }
                    }
                }
            }
        }
    }*/

    // TODO: optimize, avoid quickly alternating between cached, uncached if possible, incorporate small cachable subtrees into uncachable if makes sense
    // TODO: replace with generate render groups!
    private func generateRenderGroupsRecursively(for currentRenderObject: RenderObject, at currentPath: TreePath, in range: TreeRange, forward groups: [RenderGroup] = []) -> [RenderGroup] {
        if !range.contains(currentPath) {
            return groups
        }
        
        var updatedGroups = groups

        if updatedGroups.count == 0 {
            updatedGroups.append(CachableRenderGroup(id: nextRenderGroupId))
        }

        if currentRenderObject.hasTimedRenderValue || (currentRenderObject as? RenderObject.Uncachable) != nil {
            if !(updatedGroups.last! is UncachableRenderGroup) {
                updatedGroups.append(UncachableRenderGroup(id: nextRenderGroupId))
            }
            updatedGroups[updatedGroups.count - 1].add(currentPath)// = (updatedGroups[updatedGroups.count - 1].treeRange ?? TreeRange()).extended(with: currentPath)// = updatedGroups.last!.renderTreeMask.add(currentPath)
        } else if let currentRenderObject = currentRenderObject as? RenderObject.CacheSplit {
            updatedGroups.append(CachableRenderGroup(id: nextRenderGroupId))
            updatedGroups[updatedGroups.count - 1].add(currentPath)// = (updatedGroups[updatedGroups.count - 1].treeRange ?? TreeRange()).extended(with: currentPath)// = updatedGroups.last!.renderTreeMask.add(currentPath)
            for i in 0..<currentRenderObject.children.count {
                updatedGroups = generateRenderGroupsRecursively(for: currentRenderObject.children[i], at: currentPath/i, in: range, forward: updatedGroups)
            }
            
            updatedGroups.append(CachableRenderGroup(id: nextRenderGroupId))
        } else {
            if !(updatedGroups.last! is CachableRenderGroup) {
                updatedGroups.append(CachableRenderGroup(id: nextRenderGroupId))
            }
        
            if let currentRenderObject = currentRenderObject as? SubTreeRenderObject {
                for i in 0..<currentRenderObject.children.count {
                    updatedGroups = generateRenderGroupsRecursively(for: currentRenderObject.children[i], at: currentPath/i, in: range, forward: updatedGroups)
                }
            } else {
                updatedGroups[updatedGroups.count - 1].add(currentPath)// = (updatedGroups[updatedGroups.count - 1].treeRange ?? TreeRange()).extended(with: currentPath)// = updatedGroups.last!.renderTreeMask.add(currentPath)
            }
        }

        return updatedGroups
    }

    // TODO: might have a renderGroupingStrategy
    public func generateRenderGroups() {
        for group in renderGroups {
            if let group = group as? CachableRenderGroup {
                if let cache = group.cache {
                    availableCaches.append(cache)
                }
            }
        }

        // TODO: apply optimizations to output groups
        renderGroups = generateRenderGroupsRecursively(for: renderTree!, at: TreePath(), in: TreeRange(), forward: [RenderGroup]())
    }

    public func renderGroups(_ backendRenderer: Renderer, bounds: DRect) throws {
        for i in 0..<renderGroups.count {
            //print("RENDER GROUP", "MASK", renderGroups[i].renderTreeMask)
            if let treeRange = renderGroups[i].treeRange {
                if var group = renderGroups[i] as? CachableRenderGroup {
                    if group.cache == nil {
                        if var cache = availableCaches.popLast() {
                            try backendRenderer.resizeVirtualScreen(&cache, DSize2(bounds.topLeft + DVec2(bounds.size)))
                            group.cache = cache
                            print("Reused render cache.", "Old caches available:", availableCaches.count)
                        } else {
                            group.cache = try backendRenderer.makeVirtualScreen(size: DSize2(bounds.topLeft + DVec2(bounds.size)))
                        }
                        group.cacheInvalidated = true
                    }
                    if group.cacheInvalidated  {
                        try backendRenderer.pushVirtualScreen(group.cache!)
                        try backendRenderer.beginFrame()
                        try backendRenderer.clear(Color(0, 0, 0, 0))
                        try render(range: treeRange, with: backendRenderer)
                        try backendRenderer.endFrame()
                        try backendRenderer.popVirtualScreen()
                        group.cacheInvalidated = false
                        renderGroups[i] = group
                    }
                    // TODO: if multiple cached things follow each other, draw them in one step
                    try backendRenderer.drawVirtualScreens([group.cache!], at: [DVec2(0, 0)])
                } else {
                    try backendRenderer.beginFrame()
                    try render(range: treeRange, with: backendRenderer)
                    try backendRenderer.endFrame()
                }
            }
        }
    }

    private func render(range: TreeRange, with backendRenderer: Renderer) throws {
        /*if mask.items.count > 0 {
            let startPath = TreePath([mask.items[0].index])
            let startRenderObject = renderTree!.children[startPath[0]]
            try renderRenderObject(backendRenderer, startRenderObject, path: startPath, mask: mask)
        }*/
        try render(object: self.renderTree!, at: TreePath(), in: range, with: backendRenderer)
    }

    // TODO: maybe do layering via z?
    private func render(object currentRenderObject: RenderObject, at currentPath: TreePath, in range: TreeRange, with backendRenderer: Renderer) throws {
        if !range.contains(currentPath) {
            return
        }
        
        var nextPaths = [TreePath]()
        var nextRenderObjects = [RenderObject]()

        if let currentRenderObject = currentRenderObject as? SubTreeRenderObject {
            for i in 0..<currentRenderObject.children.count {
                let nextPath = TreePath(currentPath.segments + [i])
                if range.contains(nextPath) {
                    nextPaths.append(nextPath)
                    nextRenderObjects.append(currentRenderObject.children[i])
                }
            }
        }

        let timestamp = Date.timeIntervalSinceReferenceDate

        switch (currentRenderObject) {
        case let currentRenderObject as RenderTree:
            for i in 0..<nextPaths.count {
                try render(object: nextRenderObjects[i], at: nextPaths[i], in: range, with: backendRenderer)
            }
        case let currentRenderObject as RenderObject.IdentifiedSubTree:
            for i in 0..<nextPaths.count {
                try render(object: nextRenderObjects[i], at: nextPaths[i], in: range, with: backendRenderer)
            }
        case let currentRenderObject as RenderObject.Container:
            for i in 0..<nextPaths.count {
                try render(object: nextRenderObjects[i], at: nextPaths[i], in: range, with: backendRenderer)
            }
        case let currentRenderObject as RenderObject.Uncachable:
            for i in 0..<nextPaths.count {
                try render(object: nextRenderObjects[i], at: nextPaths[i], in: range, with: backendRenderer)
            }
        case let currentRenderObject as RenderObject.CacheSplit:
            for i in 0..<nextPaths.count {
                try render(object: nextRenderObjects[i], at: nextPaths[i], in: range, with: backendRenderer)
            }
        case let currentRenderObject as RenderObject.RenderStyle:
            for i in 0..<nextPaths.count {
                try render(object: nextRenderObjects[i], at: nextPaths[i], in: range, with: backendRenderer)
            }
            if let fillColor = currentRenderObject.fillColor {
                try backendRenderer.fillColor(fillColor.getValue(at: timestamp))
                try backendRenderer.fill()
            }
            if let strokeWidth = currentRenderObject.strokeWidth,
                let strokeColor = currentRenderObject.strokeColor {
                try backendRenderer.strokeWidth(strokeWidth)
                try backendRenderer.strokeColor(strokeColor.getValue(at: timestamp))
                try backendRenderer.stroke()
            }
            // TODO: after render, reset style to style that was present before
        case let currentRenderObject as RenderObject.Custom:
            try currentRenderObject.render(backendRenderer)
        case let currentRenderObject as RenderObject.Rect:
            try backendRenderer.beginPath()
            try backendRenderer.rect(currentRenderObject.rect)
        case let currentRenderObject as RenderObject.Text:
            if currentRenderObject.textConfig.wrap {
                try backendRenderer.multilineText(currentRenderObject.text, topLeft: currentRenderObject.topLeft, maxWidth: currentRenderObject.maxWidth ?? 0, fontConfig: currentRenderObject.textConfig.fontConfig, color: currentRenderObject.textConfig.color)
            } else {
                try backendRenderer.text(currentRenderObject.text, topLeft: currentRenderObject.topLeft, fontConfig: currentRenderObject.textConfig.fontConfig, color: currentRenderObject.textConfig.color)
            }
        default:
            print("Could not render RenderObject, implementation missing for:", currentRenderObject)
        }
    }
}