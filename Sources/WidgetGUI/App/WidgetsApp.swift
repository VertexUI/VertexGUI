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

        // TODO: this should be created in VisualApp, rendering the tree should probably be handled there

        /*guiRoot.renderObjectContext = RenderObject.Context(

            getTextBoundsSize: { renderer.getTextBoundsSize($0, fontConfig: $1, maxWidth: $2) }
        )*/

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

                let devToolsView = DeveloperToolsView()

                let devToolsGuiRoot = WidgetGUI.Root(
                    
                    rootWidget: devToolsView
                )

                /*let removeDebuggingDataHandler = guiRoot.onDebuggingDataAvailable {
                    
                    devToolsView.debuggingData = $0
                }

                let devToolsWindow = createWindow(guiRoot: devToolsGuiRoot, background: .Grey)
               
                _ = devToolsWindow.onKey {

                    if let event = $0 as? KeyUpEvent, event.key == Key.Escape {
                        
                        removeDebuggingDataHandler()
                        
                        devToolsWindow.close()
                    }
                }*/
            }
        }

        _ = window.onClose { [unowned self] in
            
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

    /*override public func onFrame(_ deltaTime: Int) {
                      
        for windowConfig in windowConfigs {
                               
            if windowConfig.guiRoot.rerenderNeeded {
                
                print("RERENDERING")
                
                windowConfig.renderer.beginFrame()
                
                windowConfig.renderer.clear(windowConfig.window.background)
                
                windowConfig.guiRoot.render(
                    with: windowConfig.renderer,
                    in: DRect(min: .zero, size: windowConfig.window.drawableSize))
                
                windowConfig.renderer.endFrame()
                
                windowConfig.window.updateContent()
            }
        }
    }*/
}