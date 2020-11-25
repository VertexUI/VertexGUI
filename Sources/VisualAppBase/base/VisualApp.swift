import Dispatch
import Foundation
import GfxMath

// TODO: why is there a specific VisualApp when App also takes a Window?, maybe find a more specific name
// TODO: should probably rename the Renderer to something like PaintingRenderer or so to avoid ambiguity with TreeSliceRenderer
open class VisualApp: App {
    public private(set) var windowContexts: [Int: WindowContext] = [:] {
        didSet {
            if windowContexts.count == 0 {
                exit()
            }
        }
    }

    public init(system: System, immediate: Bool = false) {
        super.init(system: system)
        _ = system.onTick(handleOnTick)
        _ = system.onFrame(handleOnFrame)
    }

    open func createRawWindow(options: Window.Options) -> Window {
        fatalError("createRawWindow() not implemented")
    } 

    open func createWindow(options: Window.Options, immediate: Bool = false) -> Window {
        let renderObjectTree = RenderObjectTree()

        let window = createRawWindow(options: options)
        let windowId = window.id

        _ = window.onBeforeClose { [unowned self] window in
            let context = windowContexts[windowId]!
            context.treeRenderer.destroy()
            context.renderer.destroy()
            context.tree.destroy()
            windowContexts.removeValue(forKey: windowId)
        }

        let renderer = createRenderer(for: window)

        let renderObjectContext = RenderObjectContext(getTextBoundsSize: { [unowned self] in
            let renderer = windowContexts[windowId]!.renderer
            return renderer.getTextBoundsSize($0, fontConfig: $1, maxWidth: $2)
        })
        renderObjectTree.context = renderObjectContext

        let renderObjectTreeRenderer: RenderObjectTreeRenderer
        let applicationContext = ApplicationContext(system: system, window: window)
        let treeSliceRenderer = createTreeSliceRenderer(context: applicationContext)
        if immediate {
            renderObjectTreeRenderer = ImmediateRenderObjectTreeRenderer(renderObjectTree, treeSliceRenderer: treeSliceRenderer, context: applicationContext)
        } else {
            renderObjectTreeRenderer = OptimizingRenderObjectTreeRenderer(renderObjectTree, treeSliceRenderer: treeSliceRenderer, context: applicationContext)
        }

        let context = WindowContext(
            window: window,
            renderer: renderer,
            tree: renderObjectTree,
            treeRenderer: renderObjectTreeRenderer)

        windowContexts[windowId] = context

        return window
    }

    open func createRenderer(for window: Window) -> Renderer {
        fatalError("createRenderer(for:) not implemented")
    }

    open func createTreeSliceRenderer(context: ApplicationContext) -> RenderObjectTreeSliceRenderer {
        fatalError("createTreeSliceRenderer() not implemented")
    } 

    open func handleOnTick(_ tick: Tick) {
        for context in windowContexts.values {
            context.tree.bus.down(.Tick(tick: tick))
            context.treeRenderer.tick(tick)
        }
    }

    open func handleOnFrame(_ deltaTime: Int) {
        for context in windowContexts.values {
            if context.treeRenderer.rerenderNeeded {
                renderWindow(context)
            }
        }
    }

    open func renderWindow(_ context: WindowContext) {
        context.window.makeCurrent()
        if !context.window.destroyed {
            context.renderer.beginFrame()
            context.renderer.clear(context.window.options.background)
            context.treeRenderer.render(with: context.renderer, in: DRect(min: .zero, size: context.window.drawableSize))
            context.renderer.endFrame()
            context.window.updateContent()
        }
    }
  
    public struct WindowContext {
        public var window: Window
        public var renderer: Renderer
        public var tree: RenderObjectTree
        public var treeRenderer: RenderObjectTreeRenderer
    }
}
