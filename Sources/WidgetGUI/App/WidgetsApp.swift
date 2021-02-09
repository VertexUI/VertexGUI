import Foundation
import VisualAppBase
import Events
import GfxMath

open class WidgetsApp: EventfulObject {
    public private(set) var baseApp: VisualApp
    
    public private(set) var guiRoots: [Int: Root] = [:]

    public let onTick = EventHandlerManager<Tick>()

    private var windowContexts: [Int: VisualApp.WindowContext] {
        baseApp.windowContexts
    }

    public init(baseApp: VisualApp) {
        //super.init(system: system, immediate: true)    }
        self.baseApp = baseApp
        _ = self.baseApp.system.onTick.addHandler(at: 0, handleOnTick)
        _ = self.baseApp.onSetup { [unowned self] in setup() }
    }

    /// - Parameter guiRoot: is an autoclosure. This ensures, that the window
    /// has already been created when the guiRoot is evaluated and e.g. the OpenGL context was created.
    public func createWindow(
        guiRoot guiRootBuilder: @autoclosure () -> Root,
        options: Window.Options,
        immediate: Bool = false) -> Window {
        let window = baseApp.createWindow(
            options: options,
            immediate: immediate)
        let windowId = window.id
        let context = windowContexts[windowId]!
        let guiRoot = guiRootBuilder()

        guiRoot.setup(
                      window: window,
                      getTextBoundsSize: { [unowned self] in windowContexts[windowId]!.renderer.getTextBoundsSize($0, fontConfig: $1, maxWidth: $2) },
                      measureText: { [unowned self] in windowContexts[windowId]!.window.getDrawingContext().measureText(text: $0, paint: $1) },
                      getApplicationTime: { [unowned self] in baseApp.system.currentTime },
                      getRealFps: { [unowned self] in baseApp.system.realFps },
                      createWindow: { [unowned self] in createWindow(guiRoot: $0(), options: $1, immediate: true) },
                      requestCursor: { [unowned self] in
                        baseApp.system.requestCursor($0)
                      })
      
        guiRoots[windowId] = guiRoot

        guiRoot.bounds.size = window.size
        
        _ = window.onMouse { [unowned self] in
            guiRoots[windowId]!.consume($0)
        }

        _ = window.onKey { [unowned self] in
            guiRoots[windowId]!.consume($0)
        }

        _ = window.onText { [unowned self] in
            guiRoots[windowId]!.consume($0)
        }

        _ = window.onSizeChanged { [unowned self] in
            guiRoots[windowId]!.bounds.size = $0
        }

        #if DEBUG
        _ = window.onKey { [unowned self] in
            if let event = $0 as? KeyUpEvent, event.key == Key.F12 {
                openDevTools(for: windowContexts[windowId]!.window)
           }
        }
        #endif
        
        _ = window.onBeforeClose { [unowned self] _ in
            guiRoots[windowId]!.destroy()
            guiRoots.removeValue(forKey: windowId)
        }

        if !guiRoot.renderObjectSystemEnabled {
            // TODO: TMP remove once fully transitioned to draw calls!
            _ = window.onBeforeFrame { [unowned self] _ in
                windowContexts[windowId]!.window.frameNeeded = true
            }
        }

        _ = window.onFrame { [unowned self] _ in
            // TODO: maybe store this?
            let drawingContext = windowContexts[windowId]!.window.getDrawingContext()
            drawingContext.beginDrawing()
            guiRoots[windowId]!.draw(drawingContext)
            drawingContext.endDrawing()
        }

        if let rendering = guiRoot.render() {
            context.tree.appendChild(rendering)
        }

        return window
    }

    public func openDevTools(for window: Window) {
        let devToolsView = DeveloperToolsView(guiRoots[window.id]!)
        let devToolsGuiRoot = WidgetGUI.Root(
            rootWidget: devToolsView
        )
        devToolsGuiRoot.renderObjectSystemEnabled = false
        createWindow(guiRoot: devToolsGuiRoot, options: Window.Options(
            initialPosition: .Defined(window.position + DVec2(window.size))
        ), immediate: true)
    }

    public func handleOnTick(_ tick: Tick) {
        for guiRoot in guiRoots.values {
            guiRoot.tick(tick)
        }
        onTick.invokeHandlers(tick)
    }

    open func setup() {

    }

    public func start() throws {
        try baseApp.start()
    }

    public func destroy() {
        removeAllEventHandlers()
    }

    deinit {
        destroy()
    }
}
