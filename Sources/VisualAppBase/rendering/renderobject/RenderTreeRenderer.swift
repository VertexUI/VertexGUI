import VisualAppBase
import GL
import CustomGraphicsMath
import Path
import Foundation

fileprivate protocol RenderGroup {
    var id: Int { get }
    var renderTreeMask: RenderTreeMask { get set }
}

fileprivate struct UncachableRenderGroup: RenderGroup {
    public var id: Int
    public var renderTreeMask: RenderTreeMask = RenderTreeMask()

    public init(id: Int) {
        self.id = id
    }
}

fileprivate struct CachableRenderGroup: RenderGroup {
    public var id: Int
    public var renderTreeMask: RenderTreeMask = RenderTreeMask()
    public var cache: VirtualScreen?
    public var cacheInvalidated = false

    public init(id: Int) {
        self.id = id
    }
}

// TODO: maybe rename to RenderTreeRenderer?
// TODO: maybe have a RenderTreeGroupGenerator with efficientUpdate(identified: ...) etc. + a group renderer?
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

    // TODO: maybe change to updateRenderTree(_ updatedTree: .., _ updatedPaths: ...)
    public func updateRenderTree(_ identifiedSubTree: IdentifiedSubTreeRenderObject) {
        //print("UPDATE RENDER TREE", renderTree!.idPaths)
        let (updatedRenderTree, updatedTreePath) = renderTree!.updated(identifiedSubTree)
        if let updatedTreePath = updatedTreePath {
            renderTree = updatedRenderTree
            for i in 0..<renderGroups.count {
                if var group = renderGroups[i] as? CachableRenderGroup {
                    if group.renderTreeMask.containsAny(updatedTreePath) {
                        group.cacheInvalidated = true
                        renderGroups[i] = group
                    }
                }
            }
        }
    }

    // TODO: optimize, avoid quickly alternating between cached, uncached if possible, incorporate small cachable subtrees into uncachable if makes sense
    private func generateRenderGroupsRecursively(_ renderObject: RenderObject, _ currentPath: RenderTreePath) {
        if let renderObject = renderObject as? RenderObject.Uncachable {
            if !(renderGroups[renderGroups.count - 1] is UncachableRenderGroup) {
                renderGroups.append(UncachableRenderGroup(id: nextRenderGroupId))
            }
            renderGroups[renderGroups.count - 1].renderTreeMask = renderGroups[renderGroups.count - 1].renderTreeMask.add(currentPath)
        } else if let renderObject = renderObject as? RenderObject.CacheSplit {
            renderGroups.append(CachableRenderGroup(id: nextRenderGroupId))
            renderGroups[renderGroups.count - 1].renderTreeMask = renderGroups[renderGroups.count - 1].renderTreeMask.add(currentPath)

            for i in 0..<renderObject.children.count {
                generateRenderGroupsRecursively(renderObject.children[i], currentPath/i)
            }
            
            renderGroups.append(CachableRenderGroup(id: nextRenderGroupId))
        } else {
            if !(renderGroups[renderGroups.count - 1] is CachableRenderGroup) {
                renderGroups.append(CachableRenderGroup(id: nextRenderGroupId))
            }
        
            if let renderObject = renderObject as? SubTreeRenderObject {
                for i in 0..<renderObject.children.count {
                    generateRenderGroupsRecursively(renderObject.children[i], currentPath/i)
                }
            } else {
                renderGroups[renderGroups.count - 1].renderTreeMask = renderGroups[renderGroups.count - 1].renderTreeMask.add(currentPath)
            }
        }
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
        renderGroups = [RenderGroup]()
        // TODO: if the first group contains very few items, might merge it with the following group
        renderGroups.append(CachableRenderGroup(id: nextRenderGroupId))

        for i in 0..<renderTree!.children.count {
            generateRenderGroupsRecursively(renderTree!.children[i], RenderTreePath([i]))
        }
    }

    public func renderGroups(_ backendRenderer: Renderer, bounds: DRect) throws {
        for i in 0..<renderGroups.count {
            // TODO: if multiple cached things follow each other, draw them
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
                    try renderMask(backendRenderer, group.renderTreeMask)
                    try backendRenderer.endFrame()
                    try backendRenderer.popVirtualScreen()
                    group.cacheInvalidated = false
                    renderGroups[i] = group
                }
                try backendRenderer.drawVirtualScreens([group.cache!], at: [DVec2(0, 0)])
            } else {
                try backendRenderer.beginFrame()
                try renderMask(backendRenderer, renderGroups[i].renderTreeMask)
                try backendRenderer.endFrame()
            }
        }
    }

    private func renderMask(_ backendRenderer: Renderer, _ mask: RenderTreeMask) throws {
        if mask.items.count > 0 {
            let startPath = RenderTreePath([mask.items[0].index])
            let startRenderObject = renderTree!.children[startPath[0]]
            try renderRenderObject(backendRenderer, startRenderObject, path: startPath, mask: mask)
        }
    }

    // TODO: maybe do layering via z?
    private func renderRenderObject(_ backendRenderer: Renderer, _ renderObject: RenderObject, path currentPath: RenderTreePath, mask: RenderTreeMask) throws {
        var nextPaths = [RenderTreePath]()
        var nextRenderObjects = [RenderObject]()

        if let renderObject = renderObject as? SubTreeRenderObject {
            for i in 0..<renderObject.children.count {
                let nextPath = RenderTreePath(currentPath.segments + [i])
                if mask.containsAny(nextPath) {
                    nextPaths.append(nextPath)
                    nextRenderObjects.append(renderObject.children[i])
                }
            }
        }

        switch (renderObject) {
        case let renderObject as RenderObject.IdentifiedSubTree:
            for i in 0..<nextPaths.count {
                try renderRenderObject(backendRenderer, nextRenderObjects[i], path: nextPaths[i], mask: mask)
            }
        case let renderObject as RenderObject.Container:
            for i in 0..<nextPaths.count {
                try renderRenderObject(backendRenderer, nextRenderObjects[i], path: nextPaths[i], mask: mask)
            }
        case let renderObject as RenderObject.Uncachable:
            for i in 0..<nextPaths.count {
                try renderRenderObject(backendRenderer, nextRenderObjects[i], path: nextPaths[i], mask: mask)
            }
        case let renderObject as RenderObject.CacheSplit:
            for i in 0..<nextPaths.count {
                try renderRenderObject(backendRenderer, nextRenderObjects[i], path: nextPaths[i], mask: mask)
            }
        case let renderObject as RenderObject.RenderStyle:
            for i in 0..<nextPaths.count {
                try renderRenderObject(backendRenderer, nextRenderObjects[i], path: nextPaths[i], mask: mask)
            }
            if let fillColor = renderObject.renderStyle.fillColor {
                try backendRenderer.fillColor(fillColor)
                try backendRenderer.fill()
            }
            if let strokeWidth = renderObject.renderStyle.strokeWidth,
                let strokeColor = renderObject.renderStyle.strokeColor {
                try backendRenderer.strokeWidth(strokeWidth)
                try backendRenderer.strokeColor(strokeColor)
                try backendRenderer.stroke()
            }
            // TODO: after render, reset style to style that was present before
        case let renderObject as RenderObject.Custom:
            try renderObject.render(backendRenderer)
        case let renderObject as RenderObject.Rect:
            try backendRenderer.beginPath()
            try backendRenderer.rect(renderObject.rect)
        case let renderObject as RenderObject.Text:
            if renderObject.textConfig.wrap {
                try backendRenderer.multilineText(renderObject.text, topLeft: renderObject.topLeft, maxWidth: renderObject.maxWidth ?? 0, fontConfig: renderObject.textConfig.fontConfig, color: renderObject.textConfig.color)
            } else {
                try backendRenderer.text(renderObject.text, topLeft: renderObject.topLeft, fontConfig: renderObject.textConfig.fontConfig, color: renderObject.textConfig.color)
            }
        default:
            print("Could not render RenderObject, implementation missing for:", renderObject)
        }
    }
}