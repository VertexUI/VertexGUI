import VisualAppBase
import GL
import Path

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

    public init() {}
}

// TODO: maybe rename to RenderTreeRenderer?
public class RenderTreeRenderer {
    private var renderTree: RenderTree?
    // TODO: maybe define this as a RenderState object?
    private var renderGroups = [RenderGroup]()
    
    public init() {
    }

    public func updateRenderTree(_ updatedRenderTree: RenderTree) {
        self.renderTree = updatedRenderTree
        clearRenderCache()
        generateRenderGroups()
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
            print("RECURSIVE GENERATE", currentPath, renderObject)
            renderGroups[renderGroups.count - 1].renderTreeMask = renderGroups[renderGroups.count - 1].renderTreeMask.add(currentPath)
            print("ADDED UNCACHABLE", renderGroups[renderGroups.count - 1])
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
        renderGroups = [RenderGroup]()
        // TODO: if the first group contains very few items, might merge it with the following group
        renderGroups.append(CachableRenderGroup())

        recursivelyGenerateRenderGroups(renderTree!.children[0], RenderTreePath([0]))
    }

    public func renderGroups(_ backendRenderer: Renderer) throws {
        for group in renderGroups {
            print("RENDER GROUP", group)
            if let group = group as? CachableRenderGroup {
                try renderMask(backendRenderer, group.renderTreeMask)
            } else {
                try renderMask(backendRenderer, group.renderTreeMask)
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
        case let renderObject as RenderObject.Container:
            for i in 0..<nextPaths.count {
                try renderRenderObject(backendRenderer, nextRenderObjects[i], path: nextPaths[i], mask: mask)
            }
        case let renderObject as RenderObject.Uncachable:
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