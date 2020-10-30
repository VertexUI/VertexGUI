import Foundation
import VisualAppBase
import CustomGraphicsMath

open class WidgetsApp<S: System, W: Window, R: Renderer>: VisualApp<S, W, R> {
    public typealias Renderer = R
    public private(set) var guiRoots: [ObjectIdentifier: Root] = [:]

    public init(system: System) {
        super.init(system: system, immediate: true)
    }

    /// - Parameter guiRoot: is an autoclosure. This ensures, that the window
    /// has already been created when the guiRoot is evaluated and e.g. the OpenGL context was created.
    public func createWindow(guiRoot guiRootBuilder: @autoclosure () -> Root, background: Color, immediate: Bool = false) -> Window {
        let window = super.createWindow(background: background, size: DSize2(500, 500), immediate: immediate)
        var context = windowContexts[ObjectIdentifier(window)]!
        let guiRoot = guiRootBuilder()

        guiRoots[ObjectIdentifier(window)] = guiRoot
        guiRoot.widgetContext = WidgetContext(
            window: window,
            getTextBoundsSize: { [unowned self] in windowContexts[ObjectIdentifier(window)]!.renderer.getTextBoundsSize($0, fontConfig: $1, maxWidth: $2) },
            getApplicationTime: { [unowned self] in system.currentTime },
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

        _ = window.onKey { [unowned self] in
            if let event = $0 as? KeyUpEvent, event.key == Key.F12 {
                let devToolsView = DeveloperToolsView(guiRoot)
                let devToolsGuiRoot = WidgetGUI.Root(
                    rootWidget: devToolsView
                )
                createWindow(guiRoot: devToolsGuiRoot, background: .Grey, immediate: true)
            }
        }

        _ = window.onClose {
            guiRoot.destroy()
        }

        if let rendering = guiRoot.render() {
            context.tree.appendChild(rendering)
        }

        return window
    }

    override public func onTick(_ tick: Tick) {
        for guiRoot in guiRoots.values {
            guiRoot.tick(tick)
        }
        super.onTick(tick)
    }

    override public func renderWindow(_ context: WindowContext) {
        #if DEBUG
        let startTime = Date.timeIntervalSinceReferenceDate
        #endif

        super.renderWindow(context)

        #if DEBUG
        let deltaTime = Date.timeIntervalSinceReferenceDate - startTime
        Logger.log(
            "Took \(deltaTime) seconds for rendering window.",
            level: .Message,
            context: .Performance
        )
        #endif
    }
}