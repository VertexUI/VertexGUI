import VisualAppBase
import CustomGraphicsMath

open class WidgetsApp<S: System, W: Window, R: Renderer>: VisualApp<S, W> {
    public struct WindowConfig {
        public var window: Window
        public var guiRoot: Root
        public var renderer: Renderer
    }
    public typealias Renderer = R

    private var windowConfigs: [WindowConfig] = []

    override public init(system: System) {
        super.init(system: system)
        _ = system.onFrame(render)
    }

    open func createRenderer(for window: Window) -> Renderer {
        fatalError("createRenderer() not implemented.")
    }

    public func newWindow(guiRoot: Root, background: Color) {
        let window = try! Window(background: background, size: DSize2(500, 500))
        let renderer = createRenderer(for: window)
        guiRoot.context = WidgetContext(
            getTextBoundsSize: { self.getTextBoundsSize($0, $1, $2, renderer) },
            requestCursor: {
                self.system.requestCursor($0)
            })
        guiRoot.bounds.size = window.size
        _ = window.onMouse {
            guiRoot.consumeMouseEvent($0)
        }
        _ = window.onResize {
            guiRoot.bounds.size = $0
            //guiRoot.layout()
        }
        _ = window.onClose {
            try! self.system.exit()
        }
        windowConfigs.append(WindowConfig(window: window, guiRoot: guiRoot, renderer: renderer))
    }

    open func getTextBoundsSize(_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?, _ renderer: Renderer) -> DSize2 {
        if let maxWidth = maxWidth {
            return try! renderer.getMultilineTextBoundsSize(text, fontConfig: fontConfig, maxWidth: maxWidth)
        } else {
            return try! renderer.getTextBoundsSize(text, fontConfig: fontConfig)
        }
        return DSize2(0, 0)
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
}
