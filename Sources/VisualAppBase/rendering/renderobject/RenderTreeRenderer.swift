import VisualAppBase
import GL
import CustomGraphicsMath
import Path
import Foundation

fileprivate protocol RenderGroup {
    var renderTreeMask: RenderTreeMask { get set }
}

fileprivate struct UncachableRenderGroup: RenderGroup {
    public var renderTreeMask: RenderTreeMask = RenderTreeMask()

    public init() {}
}

fileprivate struct CachableRenderGroup: RenderGroup {
    public var renderTreeMask: RenderTreeMask = RenderTreeMask()
    public var cache: VirtualScreen?
    public var cacheInvalidated = false

    public init() {}
}

// TODO: maybe rename to RenderTreeRenderer?
// TODO: maybe have a RenderTreeGroupGenerator with efficientUpdate(identified: ...) etc. + a group renderer?
public class RenderTreeRenderer {
    private var renderTree: RenderTree?
    // TODO: maybe define this as a RenderState object?
    private var renderGroups = [RenderGroup]()
    
    public init() {
    }

    public func setRenderTree(_ updatedRenderTree: RenderTree) {
        self.renderTree = updatedRenderTree
        clearRenderCache()
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

    public func clearRenderCache() {
        
    }

    // TODO: optimize, avoid quickly alternating between cached, uncached if possible, incorporate small cachable subtrees into uncachable if makes sense
    private func recursivelyGenerateRenderGroups(_ renderObject: RenderObject, _ currentPath: RenderTreePath) {
        if let renderObject = renderObject as? RenderObject.Uncachable {

            if renderGroups[renderGroups.count - 1] is UncachableRenderGroup {

            } else {
                renderGroups.append(UncachableRenderGroup())
            }
            renderGroups[renderGroups.count - 1].renderTreeMask = renderGroups[renderGroups.count - 1].renderTreeMask.add(currentPath)
        } else {
            if renderGroups[renderGroups.count - 1] is CachableRenderGroup {

            } else {
                renderGroups.append(CachableRenderGroup())
            }
            renderGroups[renderGroups.count - 1].renderTreeMask = renderGroups[renderGroups.count - 1].renderTreeMask.add(currentPath)
        
            if let renderObject = renderObject as? SubTreeRenderObject {
                for i in 0..<renderObject.children.count {
                    recursivelyGenerateRenderGroups(renderObject.children[i], RenderTreePath(currentPath.segments + [i]))
                }
            }
        }
    }

    // TODO: might have a renderGroupingStrategy
    public func generateRenderGroups() {
        // TODO: instead of simply replacing everything, check for equality
        // since replacing for now, need to delete all cache textures
        for group in renderGroups {
            if let group = group as? CachableRenderGroup {
                if let cache = group.cache {
                    try! cache.delete()
                }
            }
        }
        renderGroups = [RenderGroup]()
        // TODO: if the first group contains very few items, might merge it with the following group
        renderGroups.append(CachableRenderGroup())

        recursivelyGenerateRenderGroups(renderTree!.children[0], RenderTreePath([0]))
    }

    public func renderGroups(_ backendRenderer: Renderer, bounds: DRect) throws {
        for i in 0..<renderGroups.count {
            // TODO: if multiple cached things follow each other, draw them
            if var group = renderGroups[i] as? CachableRenderGroup {
                if group.cache == nil || group.cacheInvalidated {
                    group.cache = try backendRenderer.makeVirtualScreen(size: DSize2(bounds.topLeft + DVec2(bounds.size)))
                    renderGroups[i] = group
                    try backendRenderer.pushVirtualScreen(group.cache!)
                    try backendRenderer.beginFrame()
                    try backendRenderer.clear(Color(120, 160, 130, 255))
                    try renderMask(backendRenderer, group.renderTreeMask)
                    try backendRenderer.endFrame()
                    try backendRenderer.popVirtualScreen()
                    group.cacheInvalidated = false
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

public struct RenderState {
    
}