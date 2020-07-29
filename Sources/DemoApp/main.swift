import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import Dispatch
import CustomGraphicsMath
import Path
import GL
import CSDL2

// TODO: create a subclass of App, DesktopApp which supports windows/screens which can support different resolutions --> renderContexts --> different text boundsSize
open class TwoDGraphicalApp: App<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {
    //public typealias Renderables = WidgetGUI.Renderables<System, Window, Renderer>
    open var window: Window?
    open var renderer: Renderer?
    open var devToolsWindow: Window?
    open var devToolsRenderer: Renderer?

    open var guiRoot: WidgetGUI.Root
    open var devToolsGuiRoot: WidgetGUI.Root
    open var devToolsView: DeveloperToolsView

    private var cacheFramebuffer = GLMap.UInt()
    private var cacheTexture = GLMap.UInt()
    private var cacheDepthStencil = GLMap.UInt()
    private var screenVAO = GLMap.UInt()
    private var virtualScreen: VirtualScreen?

    private var compositionShader = Shader(
        vertex: try! String(contentsOf: Path.cwd/"Sources/DemoApp/Assets/CompositionVertex.glsl"),
        fragment: try! String(contentsOf: Path.cwd/"Sources/DemoApp/Assets/CompositionFragment.glsl")
    )

    override public init() {
        let page = TwoDWorldPage()
        guiRoot = WidgetGUI.Root(
            rootWidget: page)

        let devToolsView = DeveloperToolsView()
        devToolsGuiRoot = WidgetGUI.Root(
            rootWidget: devToolsView
        )
        self.devToolsView = devToolsView

        super.init()
        guiRoot.context = WidgetContext(
            getTextBoundsSize: getTextBoundsSize,
            requestCursor: {
                self.system!.requestCursor($0)
            })

        devToolsGuiRoot.context = WidgetContext(
            getTextBoundsSize: getTextBoundsSize,
            requestCursor: {
                self.system!.requestCursor($0)
            })
            /*TextConfigProvider(
                child: page, 
                config: TextConfig(fontConfig: Self.defaultFontConfig, color: .Green, wrap: false)))*/
    }

    override open func setup() throws {
        self.system = try System()
        self.window = try Window(background: Color(50, 50, 50, 255), size: DSize2(800, 600))
        self.renderer = try Renderer(window: window!)
        //self.context = try RenderContext(system: system!, window: window!, renderer: renderer!)
        self.guiRoot.bounds = DRect(topLeft: DPoint2(0,0), size: window!.size)
        try self.guiRoot.layout()

//        virtualScreen = try renderer!.makeVirtualScreen(size: DSize2(window!.drawableSize.width, window!.drawableSize.height))

        self.devToolsWindow = try Window(background: Color(50, 50, 50, 255), size: DSize2(800, 600))
        self.devToolsRenderer = try Renderer(window: devToolsWindow!)
        self.devToolsGuiRoot.bounds = DRect(topLeft: DPoint2(0,0), size: devToolsWindow!.size)
        try self.devToolsGuiRoot.layout()
    
        _ = guiRoot.onDebuggingDataAvailable {
            self.devToolsView.debuggingData = $0
        }
        _ = self.window!.onResize(handleWindowResized)
        _ = self.window!.onMouse(handleMouseEvent)
        _ = self.window!.onClose {
            try! self.system!.exit()
        }
        _ = self.devToolsWindow!.onResize(handledevToolsWindowResized)
        _ = self.devToolsWindow!.onMouse(handledevToolsWindowMouseEvent)
        _ = self.devToolsWindow!.onClose {
            try! self.system!.exit()
        }
        _ = self.system!.onFrame(render)
    }

    open func getTextBoundsSize(_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2 {
        if let renderer = renderer {
            if let maxWidth = maxWidth {
                return try! renderer.getMultilineTextBoundsSize(text, fontConfig: fontConfig, maxWidth: maxWidth ?? 0)
            } else {
                return try! renderer.getTextBoundsSize(text, fontConfig: fontConfig)
            }
        }
        return DSize2(0, 0)
    }

    open func handleMouseEvent(_ mouseEvent: RawMouseEvent) {
        self.guiRoot.consumeMouseEvent(mouseEvent)
    }

    open func handledevToolsWindowMouseEvent(_ mouseEvent: RawMouseEvent) {
        self.devToolsGuiRoot.consumeMouseEvent(mouseEvent)
    }

    open func handleWindowResized(newSize: DSize2) {
        self.guiRoot.bounds.size = newSize
        do {
            try self.guiRoot.layout()
           // try renderer!.resizeVirtualScreen(&virtualScreen!, window!.drawableSize)
        } catch {
            print("Error during handleWindowResized().")
        }
    }

    open func handledevToolsWindowResized(newSize: DSize2) {
        self.devToolsGuiRoot.bounds.size = newSize
        try! self.devToolsGuiRoot.layout()
    }

    open func render(deltaTime: Int) throws {
        // useless rendering to virtualScreen just as a test 
    //    try renderer!.pushVirtualScreen(virtualScreen!)
        try renderer!.beginFrame()
        //try renderer!.clear(window!.background)
        try guiRoot.render(renderer: renderer!)
        try renderer!.endFrame()
      //  try renderer!.popVirtualScreen()
      //  try renderer!.drawVirtualScreens([virtualScreen!])
        try window!.updateContent()

        try devToolsRenderer!.beginFrame()
        try devToolsRenderer!.clear(devToolsWindow!.background)
        try devToolsGuiRoot.render(renderer: devToolsRenderer!)
        try devToolsRenderer!.endFrame()
        try devToolsWindow!.updateContent()
    }
}

let app = TwoDGraphicalApp()

do {
    try app.start()
} catch {
    print("Error while running app", error)
}