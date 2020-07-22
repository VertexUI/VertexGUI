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
    open var debuggerWindow: Window?
    open var debuggerRenderer: Renderer?

    open var guiRoot: WidgetGUI.Root
    open var debuggerRoot: WidgetGUI.Root
    open var debugger: RenderingDebugger

    private var cacheFramebuffer = GLMap.UInt()
    private var cacheTexture = GLMap.UInt()
    private var cacheDepthStencil = GLMap.UInt()
    private var screenVAO = GLMap.UInt()
    private var virtualScreen: VirtualScreen?

    private var compositionShader = Shader(
        vertex: try! String(contentsOf: Path.cwd/"Sources/DemoApp/assets/CompositionVertex.glsl"),
        fragment: try! String(contentsOf: Path.cwd/"Sources/DemoApp/assets/CompositionFragment.glsl")
    )

    override public init() {

        let page = TwoDVoxelRaycastPage()
        guiRoot = WidgetGUI.Root(
            rootWidget: page)

        let debugger = RenderingDebugger()
        debuggerRoot = WidgetGUI.Root(
            rootWidget: debugger
        )
        self.debugger = debugger

        super.init()
        guiRoot.context = WidgetContext(
            defaultFontFamily: FontFamily(
                name: "Roboto",
                faces: [
                    FontFace(path: (Path.cwd/"Sources/DemoApp/assets/Roboto-Regular.ttf").string, weight: .Regular, style: .Normal)
                ]
            ), getTextBoundsSize: getTextBoundsSize)

        debuggerRoot.context = WidgetContext(
            defaultFontFamily: FontFamily(
                name: "Roboto",
                faces: [
                    FontFace(path: (Path.cwd/"Sources/DemoApp/assets/Roboto-Regular.ttf").string, weight: .Regular, style: .Normal)
                ]
            ), getTextBoundsSize: getTextBoundsSize)
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

        self.debuggerWindow = try Window(background: Color(50, 50, 50, 255), size: DSize2(800, 600))
        self.debuggerRenderer = try Renderer(window: debuggerWindow!)
        self.debuggerRoot.bounds = DRect(topLeft: DPoint2(0,0), size: debuggerWindow!.size)
        try self.debuggerRoot.layout()
    
        _ = guiRoot.onDebuggingDataAvailable {
            self.debugger.debuggingData = $0
            print("GUI ROOT DEBUGGING DATA AVAILABLE PUBSLIH")
        }
        _ = self.window!.onResize(handleWindowResized)
        _ = self.window!.onMouse(handleMouseEvent)
        _ = self.debuggerWindow!.onResize(handleDebuggerWindowResized)
        _ = self.debuggerWindow!.onMouse(handleDebuggerWindowMouseEvent)
        _ = self.system!.onFrame(render)
    }

    open func getTextBoundsSize(_ text: String, _ config: TextConfig, _ maxWidth: Double?) -> DSize2 {
        if let renderer = renderer {
            if config.wrap {
                return try! renderer.getMultilineTextBoundsSize(text, maxWidth: maxWidth ?? 0, fontConfig: config.fontConfig)
            } else {
                return try! renderer.getTextBoundsSize(text, fontConfig: config.fontConfig)
            }
        }
        return DSize2(0, 0)
    }

    open func handleMouseEvent(_ mouseEvent: RawMouseEvent) {
        self.guiRoot.consumeMouseEvent(mouseEvent)
    }

    open func handleDebuggerWindowMouseEvent(_ mouseEvent: RawMouseEvent) {
        self.debuggerRoot.consumeMouseEvent(mouseEvent)
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

    open func handleDebuggerWindowResized(newSize: DSize2) {
        self.debuggerRoot.bounds.size = newSize
        try! self.debuggerRoot.layout()
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

        try debuggerRenderer!.beginFrame()
        try debuggerRenderer!.clear(debuggerWindow!.background)
        try debuggerRoot.render(renderer: debuggerRenderer!)
        try debuggerRenderer!.endFrame()
        try debuggerWindow!.updateContent()
    }
}

let app = TwoDGraphicalApp()

do {
    try app.start()
} catch {
    print("Error while running app", error)
}