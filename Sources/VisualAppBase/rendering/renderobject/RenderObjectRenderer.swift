import VisualAppBase

/*public enum RenderTreeMask {
    indirect case Sub(index: Int, sub: [RenderTreeMask])
    case Leaf(index: Int)
    case Empty
}*/

public struct RenderTreePath {
    public var segments: [Int]

    public var count: Int {
        return segments.count
    }

    public init(_ segments: [Int]) {
        self.segments = segments
    }

    public subscript(index: Int) -> Int {
        get {
            segments[index]
        }
        set {
            segments[index] = newValue
        }
    }
}

public protocol RenderTreeMaskItem {
    var index: Int { get set }

    typealias SubMask = RenderTreeSubMaskItem
}

public struct RenderTreeSubMaskItem: RenderTreeMaskItem {
    public var index: Int
    public var items: [RenderTreeMaskItem]

    public init(index: Int, items: [RenderTreeMaskItem]) {
        self.index = index
        self.items = items
    }
}

public struct RenderTreeMaskLeafItem: RenderTreeMaskItem {
    public var index: Int

    public init(index: Int) {
        self.index = index
    }
}

public struct RenderTreeMask {
    public var items: [RenderTreeMaskItem]

    public init(_ items: [RenderTreeMaskItem] = [RenderTreeMaskItem]()) {
        self.items = items
    }

    /// - Returns whether any leaf item path equals or contains the given path.
    public func containsAny(_ path: RenderTreePath) -> Bool {
        if path.count == 0 {
            return true
        }

        var checkItems = items
        var pathSegmentIndex = 0
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
                    }
                }
            }
        }
        return false
    }
}

public protocol RenderGroup {
    var renderTreeMask: RenderTreeMask { get set }
}

public struct NoncachableRenderGroup: RenderGroup {
    public var renderTreeMask: RenderTreeMask = RenderTreeMask()

    public init() {}
}

public struct CachableRenderGroup: RenderGroup {
   public var renderTreeMask: RenderTreeMask = RenderTreeMask()

    public init() {}
}

// TODO: maybe rename to RenderTreeRenderer?
public class RenderObjectRenderer {
    private var renderTree: RenderTree?
    // TODO: maybe define this as a RenderState object?
    private var renderGroups = [RenderGroup]()
    
    public init() {
        var group = CachableRenderGroup()
        group.renderTreeMask.items.append(RenderTreeMaskLeafItem(index: 0))
        renderGroups.append(group)
    }

    public func updateRenderTree(_ newTree: RenderTree) {
        self.renderTree = newTree
        clearRenderCache()
    }

    public func clearRenderCache() {
        
    }

    public func renderGroups(_ backendRenderer: Renderer) throws {
        for group in renderGroups {
            try renderMask(backendRenderer, group.renderTreeMask)
        }
    }

    /*public func renderTree(_ backendRenderer: Renderer, _ mask: RenderTreeMask) throws {
        if let renderTree = renderTree {
            for child in renderTree.children {
                //try renderRenderObject(backendRenderer, child)
            }
        }
    }*/

    private func renderMask(_ backendRenderer: Renderer, _ mask: RenderTreeMask) throws {
        let startPath = RenderTreePath([mask.items[0].index])
        let startRenderObject = renderTree!.children[startPath[0]]
        try renderRenderObject(backendRenderer, startRenderObject, path: startPath, mask: mask)
        /*var currentPath = RenderTreePath([mask[0].index])
        var currentRenderObject: RenderObject = renderTree.children[currentPath[0]]
        while true {

        }*/
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
        case let renderObject as RenderObject.Custom:
            try renderObject.render(backendRenderer)
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