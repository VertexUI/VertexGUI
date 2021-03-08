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
        //_ = system.onFrame(handleOnFrame)
    }

    open func createRawWindow(options: Window.Options) -> Window {
        fatalError("createRawWindow() not implemented")
    } 

    open func createWindow(options: Window.Options, immediate: Bool = false) -> Window {
        let renderObjectTree = RenderObjectTree()

        let window = createRawWindow(options: options)
        window.frameNeeded = false
        let windowId = window.id

        let applicationContext = ApplicationContext(system: system, window: window)

        let context = WindowContext(
            window: window,
            tree: renderObjectTree)

        _ = window.onFrame { [unowned self] _ in
            renderWindow(context)
        }

        _ = window.onBeforeClose { [unowned self] window in
            let context = windowContexts[windowId]!
            context.tree.destroy()
            windowContexts.removeValue(forKey: windowId)
        }

        windowContexts[windowId] = context

        return window
    }

    open func handleOnTick(_ tick: Tick) {
        for context in windowContexts.values {
            context.tree.bus.down(.Tick(tick: tick))
        }
    }

    open func renderWindow(_ context: WindowContext) {

    }
  
    public struct WindowContext {
        public var window: Window
        public var tree: RenderObjectTree
    }
}
