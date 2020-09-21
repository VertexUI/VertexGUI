import VisualAppBase
import CustomGraphicsMath

open class WidgetsApp<S: System, W: Window, R: Renderer>: VisualApp<S, W> {
    public struct WindowConfig {
        public var window: Window
        public var guiRoot: Root
        public var renderer: Renderer
    }
    public typealias Renderer = R

    private var windowConfigs = ObservableArray<WindowConfig>()

    override public init(system: System) {
        super.init(system: system)

        _ = system.onFrame(render)

        _ = windowConfigs.onChanged { [unowned self] _ in
            if windowConfigs.count == 0 {
                exit()
            }
        }
    }

    open func createRenderer(for window: Window) -> Renderer {
        fatalError("createRenderer() not implemented.")
    }

    /// - Parameter guiRoot: is an autoclosure. This ensures, that the window
    /// has already been created when the guiRoot is evaluated and e.g. the OpenGL context was created.
    public func newWindow(guiRoot guiRootBuilder: @autoclosure () -> Root, background: Color) -> Window {
        let window = try! Window(background: background, size: DSize2(500, 500))

        let renderer = createRenderer(for: window)

        let guiRoot = guiRootBuilder()

        guiRoot.context = WidgetContext(
            window: window,
            getTextBoundsSize: { renderer.getTextBoundsSize($0, fontConfig: $1, maxWidth: $2) },
            requestCursor: {
                self.system.requestCursor($0)
            })

        guiRoot.bounds.size = window.size
        
        _ = window.onMouse {
            guiRoot.consume($0)
        }

        _ = window.onKey {
            guiRoot.consume($0)
        }

        _ = window.onText {
            guiRoot.consume($0)
        }

        _ = window.onResize {
            guiRoot.bounds.size = $0
        }

        _ = window.onKey { [unowned guiRoot, unowned self] in

            if let event = $0 as? KeyUpEvent, event.key == Key.F12 {

                let devToolsView = DeveloperToolsView()

                let devToolsGuiRoot = WidgetGUI.Root(
                    rootWidget: devToolsView
                )

                let removeDebuggingDataHandler = guiRoot.onDebuggingDataAvailable {
                    devToolsView.debuggingData = $0
                }

                let devToolsWindow = newWindow(guiRoot: devToolsGuiRoot, background: .Grey)
               
                _ = devToolsWindow.onKey { [unowned devToolsWindow] in

                    if let event = $0 as? KeyUpEvent, event.key == Key.Escape {
                        removeDebuggingDataHandler()
                        devToolsWindow.close()
                    }
                }
            }
        }

        _ = window.onClose { [unowned self, unowned window, unowned guiRoot] in
            guiRoot.destroy()
            windowConfigs.removeAll(where: { $0.window === window })
        }

        windowConfigs.append(WindowConfig(window: window, guiRoot: guiRoot, renderer: renderer))

        return window
    }

    public func render(deltaTime: Int) {
        for windowConfig in windowConfigs {
            do {
                try windowConfig.renderer.beginFrame()
                try windowConfig.renderer.clear(windowConfig.window.background)
                try windowConfig.guiRoot.render(with: windowConfig.renderer)
                try windowConfig.renderer.endFrame()
                try windowConfig.window.updateContent()
            } catch {
                print("Error in App render() for window:", windowConfig.window, error)
            }
        }
    }

    override open func exit() {
        try! system.exit()
    }
}
