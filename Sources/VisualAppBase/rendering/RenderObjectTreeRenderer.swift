import VisualAppBase
import CustomGraphicsMath
import Path
import Foundation

public protocol RenderGroup {
    var id: Int { get }
    //var treeMask: RenderObjectTreeMask { get set }
    var treeRange: TreeRange? { get set }

    var isEmpty: Bool { get }

    mutating func add(_ path: TreePath)
}

public extension RenderGroup {
    var isEmpty: Bool {
        treeRange == nil
    }

    mutating func add(_ path: TreePath) {
        if var treeRange = treeRange {
            treeRange.extend(with: path)
            self.treeRange = treeRange
        } else {
            self.treeRange = TreeRange(from: path, to: path)
        }
    }
}

public struct UncachableRenderGroup: RenderGroup {
    public var id: Int
    public var treeRange: TreeRange? = nil

    public init(id: Int) {
        self.id = id
    }
}

public struct CachableRenderGroup: RenderGroup {
    public var id: Int
    public var treeRange: TreeRange? = nil
    public var cache: VirtualScreen?
    public var cacheInvalidated = false

    public init(id: Int) {
        self.id = id
    }
}

// TODO: give rendering an extra package outside of VisualAppBase
// TODO: maybe rename to RenderObjectTreeRenderer?
// TODO: maybe have a RenderObjectTreeGroupGenerator with efficientUpdate(identified: ...) etc. + a group renderer?
// TODO: create a RenderState --> contains RenderObjectTree, Transitions and more depending on RenderStrategy, maybe
public class RenderObjectTreeRenderer {
    public struct DebuggingData {
        public var tree: RenderObjectTree
        public var sequence: [RenderSequenceItem]

        public init(tree: RenderObjectTree, sequence: [RenderSequenceItem]) {
            self.tree = tree
            self.sequence = sequence
        }
    }

    public struct RenderSequenceItem {
        public var range: TreeRange?
        public var cachable: Bool

        public init(range: TreeRange?, cachable: Bool) {
            self.range = range
            self.cachable = cachable
        }
    }

    private var tree: RenderObjectTree
    private var sequence: [RenderSequenceItem] = []
    // TODO: maybe define this as a RenderState object?
    //public var renderSequence = [RenderGroup]()
    //private var _nextRenderGroupId = 0
    /*private var nextRenderGroupId: Int {
        get {
            defer { _nextRenderGroupId += 1 }
            return _nextRenderGroupId
        }
    }*/
    //private var availableCaches = [VirtualScreen]()
    public var debuggingData: DebuggingData {
        DebuggingData(tree: tree, sequence: sequence)
    }

    private var renderObjectMeta: [ObjectIdentifier: Any] = [:]
    
    public init(_ tree: RenderObjectTree) {
        self.tree = tree
    }

    public func refresh() {
        sequence = [RenderSequenceItem(range: TreeRange(), cachable: false)]
    }

    public func processUpdate(_ update: RenderObjectTree.Update) {
        refresh()
        // TODO: delete RenderObjectMeta here!
    }

    /*public func setRenderObjectTree(_ tree: RenderObjectTree) {
        self.tree = tree
        generaterenderSequence()
    }*/

    /*public func processUpdate(_ update: RenderTree.Update) {
        guard case let .Replace(path, oldObject, newObject) = update else {
            fatalError("Unsupported update.")
        }
        //print("UPDATE RENDER TREE", tree!.idPaths)
        // TODO: tree comparison
        let (updatedRenderObjectTree, updatedSubTreePath) = tree!.updated(identifiedSubTree)
        var updatedRenderObjectTypePaths = [updatedSubTreePath]
        tree = updatedRenderObjectTree
        print("TREE UPDATE", updatedSubTreePath)

        var updatedTypeGroupIndices = Set<Int>()
        for i in 0..<renderSequence.count {
            if let treeRange = renderSequence[i].treeRange {
                if var group = renderSequence[i] as? CachableRenderGroup {
                    if treeRange.contains(updatedSubTreePath) {
                        group.cacheInvalidated = true
                        renderSequence[i] = group
                    }
                }
                
                for updatedTypePath in updatedRenderObjectTypePaths {
                    if treeRange.contains(updatedTypePath) {
                        updatedTypeGroupIndices.insert(i)
                        if var group = renderSequence[i] as? CachableRenderGroup, let cache = group.cache {
                           group.cache = nil
                           renderSequence[i] = group
                           availableCaches.append(cache) 
                        }
                    }
                }
            }
        }

        //generaterenderSequence()
        //return

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
                    if let groupRangeStart = renderSequence[i].treeRange?.start {
                        compoundStart = groupRangeStart 
                    }
                }
                if let groupRangeEnd = renderSequence[i].treeRange?.end {
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

        var updatedrenderSequence = [RenderGroup]()
        for i in 0..<groupUpdateBatchRanges.count {
            let batchGroupIndices = groupUpdateBatches[i]
            guard let batchRange = groupUpdateBatchRanges[i] else {
                continue
            }

            var newrenderSequence = generaterenderSequenceRecursively(for: tree!, at: TreePath(), in: batchRange)
            for i in 0..<newrenderSequence.count {
                if var newGroup = newrenderSequence[i] as? CachableRenderGroup {
                    //newGroup.cacheInvalidated = true
                    newrenderSequence[i] = newGroup
                }
            }

            let precedingReusablerenderSequence: [RenderGroup]
            if i == 0 {
                if let firstBatchGroupIndex = batchGroupIndices.first, firstBatchGroupIndex > 0 {
                    precedingReusablerenderSequence = Array(renderSequence[0..<firstBatchGroupIndex])
                } else {
                    precedingReusablerenderSequence = []
                }
            } else {
                let precedingBatchGroupIndices = groupUpdateBatches[i - 1]
                let precedingEndIndex = precedingBatchGroupIndices.last!
                let currentStartIndex = batchGroupIndices.first!
                precedingReusablerenderSequence = Array(renderSequence[precedingEndIndex + 1..<currentStartIndex])
            }
            updatedrenderSequence.append(contentsOf: precedingReusablerenderSequence)
            updatedrenderSequence.append(contentsOf: newrenderSequence)
        }
        if let lastBatch = groupUpdateBatches.last, let lastUpdatedGroupIndex = lastBatch.last {
            updatedrenderSequence.append(contentsOf: Array(renderSequence[lastUpdatedGroupIndex...]))
        }

        renderSequence = updatedrenderSequence
        optimizeGroups()
        //generaterenderSequence()
    }

    /// Optimizes groups by removing empty ones.
    private func optimizeGroups() {
        var updatedGroups = [RenderGroup]()
        for group in renderSequence {
            if !group.isEmpty {
                updatedGroups.append(group)
            }
        }
        renderSequence = updatedGroups
    }*/

    /*
    Unfinished iterative definition
    private func generaterenderSequence(for mask: RenderObjectTreeMask? = nil) -> [RenderGroup] {
        var groups: [RenderGroup] = [CachableRenderGroup(id: nextRenderGroupId)]

        var currentPath = TreePath([0])
        var parents: [SubTreeRenderObject] = [.Container(tree!.children)]
        //var checkObjects = tree!.children
        while parents.count > 0 {
            for i in 0..<parents.last!.children.count {
                let object = parents.last!.children[i]
                let objectPath = currentPath/i

                if mask == nil || mask!.containsAny(objectPath) {
                    if object.hasTimedRenderValue || object is RenderObject.Uncachable {
                        if !(groups.last! is UncachableRenderGroup) {
                            groups.append(UncachableRenderGroup(id: nextRenderGroupId))
                        }

                        groups[groups.count - 1].treeMask = groups.last!.treeMask.add(objectPath)
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
    /*private func generaterenderSequenceRecursively(for currentRenderObject: RenderObject, at currentPath: TreePath, in range: TreeRange, forward groups: [RenderGroup] = []) -> [RenderGroup] {
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
            updatedGroups[updatedGroups.count - 1].add(currentPath)// = (updatedGroups[updatedGroups.count - 1].treeRange ?? TreeRange()).extended(with: currentPath)// = updatedGroups.last!.treeMask.add(currentPath)
        } else if let currentRenderObject = currentRenderObject as? RenderObject.CacheSplit {
            updatedGroups.append(CachableRenderGroup(id: nextRenderGroupId))
            updatedGroups[updatedGroups.count - 1].add(currentPath)// = (updatedGroups[updatedGroups.count - 1].treeRange ?? TreeRange()).extended(with: currentPath)// = updatedGroups.last!.treeMask.add(currentPath)
            for i in 0..<currentRenderObject.children.count {
                updatedGroups = generaterenderSequenceRecursively(for: currentRenderObject.children[i], at: currentPath/i, in: range, forward: updatedGroups)
            }
            
            updatedGroups.append(CachableRenderGroup(id: nextRenderGroupId))
        } else {
            if !(updatedGroups.last! is CachableRenderGroup) {
                updatedGroups.append(CachableRenderGroup(id: nextRenderGroupId))
            }
        
            if let currentRenderObject = currentRenderObject as? SubTreeRenderObject {
                for i in 0..<currentRenderObject.children.count {
                    updatedGroups = generaterenderSequenceRecursively(for: currentRenderObject.children[i], at: currentPath/i, in: range, forward: updatedGroups)
                }
            } else {
                updatedGroups[updatedGroups.count - 1].add(currentPath)// = (updatedGroups[updatedGroups.count - 1].treeRange ?? TreeRange()).extended(with: currentPath)// = updatedGroups.last!.treeMask.add(currentPath)
            }
        }

        return updatedGroups
    }*/

    // TODO: might have a renderGroupingStrategy
    /*public func generaterenderSequence() {
        for group in renderSequence {
            if let group = group as? CachableRenderGroup {
                if let cache = group.cache {
                    availableCaches.append(cache)
                }
            }
        }

        // TODO: apply optimizations to output groups
        renderSequence = generaterenderSequenceRecursively(for: tree!, at: TreePath(), in: TreeRange())
        optimizeGroups()
    }*/

    public func render(with backendRenderer: Renderer, in bounds: DRect) throws {
        for i in 0..<sequence.count {
            if let range = sequence[i].range {
                /*if var group = renderSequence[i] as? CachableRenderGroup {
                    if group.cache == nil {
                        if var cache = availableCaches.popLast() {
                            backendRenderer.resizeVirtualScreen(&cache, DSize2(bounds.min + DVec2(bounds.size)))
                            group.cache = cache
                            print("Reused render cache.", "Old caches available:", availableCaches.count)
                        } else {
                            group.cache = backendRenderer.makeVirtualScreen(size: DSize2(bounds.min + DVec2(bounds.size)))
                        }
                        group.cacheInvalidated = true
                    }
                    if group.cacheInvalidated  {
                        backendRenderer.pushVirtualScreen(group.cache!)
                        backendRenderer.beginFrame()
                        backendRenderer.clear(Color(0, 0, 0, 0))
                        try render(range: range, with: backendRenderer)
                        backendRenderer.endFrame()
                        backendRenderer.popVirtualScreen()
                        group.cacheInvalidated = false
                        renderSequence[i] = group
                    }
                    backendRenderer.beginFrame()
                    // TODO: if multiple cached things follow each other, draw them in one step
                    backendRenderer.drawVirtualScreens([group.cache!], at: [DVec2(0, 0)])
                    backendRenderer.endFrame()
                } else {*/
                    backendRenderer.beginFrame()
                    try render(range: range, with: backendRenderer)
                    backendRenderer.endFrame()
               // }
            }
        }
    }

    private func render(range: TreeRange, with backendRenderer: Renderer) throws {
        try render(object: self.tree, at: TreePath(), in: range, with: backendRenderer)
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

        case let currentRenderObject as RenderObjectTree:
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
            // TODO: implement tracking current render style as layers, whenever moving out of a child render style,
            // need to reapply the next parent
           // var performFill = false
           // var performStroke = false

            if let fillRenderValue = currentRenderObject.fill {

                let fill = fillRenderValue.getValue(at: timestamp)

                if fillRenderValue.isTimed {

                    switch fill {
                    case let .Color(value):
                        backendRenderer.fillColor(value)
                    case let .Image(value, position):
                        backendRenderer.fillImage(value, position: position)
                    }

                } else {
                    
                    switch fill {
                    case let .Color(value):
                        backendRenderer.fillColor(value)
                    
                    case let .Image(value, position):
                        let id = ObjectIdentifier(currentRenderObject)
                        
                        if let cachedLoadedFill = renderObjectMeta[id] as? LoadedFill {
                            backendRenderer.applyFill(cachedLoadedFill)
                        } else {
                            let loadedFill = backendRenderer.fillImage(value, position: position)
                            renderObjectMeta[id] = loadedFill
                        }
                    }
                }

               // performFill = true

            } else {
                backendRenderer.fillColor(.Transparent)
            }

            if let strokeWidth = currentRenderObject.strokeWidth,

                let strokeColor = currentRenderObject.strokeColor {

                backendRenderer.strokeWidth(strokeWidth)
                backendRenderer.strokeColor(strokeColor.getValue(at: timestamp))

               // performStroke = true

            } else {

                backendRenderer.strokeWidth(0)
                backendRenderer.strokeColor(.Transparent)

            }

            for i in 0..<nextPaths.count {
                try render(object: nextRenderObjects[i], at: nextPaths[i], in: range, with: backendRenderer)
            }

            backendRenderer.fillColor(.Transparent)
            backendRenderer.strokeWidth(0)
            backendRenderer.strokeColor(.Transparent)
            // TODO: after render, reset style to style that was present before

        case let currentRenderObject as RenderObject.Translation:
            backendRenderer.translate(currentRenderObject.translation)
            for i in 0..<nextPaths.count {
                try render(object: nextRenderObjects[i], at: nextPaths[i], in: range, with: backendRenderer)
            }
            backendRenderer.translate(-currentRenderObject.translation)

        case let renderObject as RenderObject.Clip:

            // TODO: right now, clip areas can't be nested --> implement clip area bounds stack

            backendRenderer.clipArea(bounds: renderObject.clipBounds)

            for i in 0..<nextPaths.count {
                try render(object: nextRenderObjects[i], at: nextPaths[i], in: range, with: backendRenderer)
            }

            backendRenderer.releaseClipArea()

        case let currentRenderObject as RenderObject.Custom:
            // TODO: this might be a dirty solution
            backendRenderer.endFrame()
            try currentRenderObject.render(backendRenderer)
            backendRenderer.beginFrame()

        case let currentRenderObject as RenderObject.Rectangle:
            backendRenderer.beginPath()
            if let cornerRadii = currentRenderObject.cornerRadii {
                backendRenderer.roundedRectangle(currentRenderObject.rect, cornerRadii: cornerRadii)
            } else {
                backendRenderer.rectangle(currentRenderObject.rect)
            }
            backendRenderer.fill()
            backendRenderer.stroke()

        case let currentRenderObject as RenderObject.Ellipse:

            backendRenderer.beginPath()

            backendRenderer.ellipse(currentRenderObject.bounds)

            backendRenderer.fill()

            backendRenderer.stroke()

        case let currentRenderObject as RenderObject.LineSegment:
            backendRenderer.beginPath()
            backendRenderer.lineSegment(from: currentRenderObject.start, to: currentRenderObject.end)
            backendRenderer.fill()
            backendRenderer.stroke()

        case let currentRenderObject as RenderObject.Text:

            backendRenderer.text(currentRenderObject.text, fontConfig: currentRenderObject.fontConfig, color: currentRenderObject.color, topLeft: currentRenderObject.topLeft, maxWidth: currentRenderObject.maxWidth)

        default:
            print("Could not render RenderObject, implementation missing for:", currentRenderObject)
        }
    }
}