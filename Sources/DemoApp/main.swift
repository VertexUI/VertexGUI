import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import Dispatch
import CustomGraphicsMath
import Path

print("APP")

// TODO: create a subclass of App, DesktopApp which supports windows/screens which can support different resolutions --> renderContexts --> different text boundsSize
open class TwoDGraphicalApp: App<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {
    //public typealias Renderables = WidgetGUI.Renderables<System, Window, Renderer>
    open var window: Window?
    open var renderer: Renderer?
    //open var renderContext: RenderContext?

    open var guiRoot: WidgetGUI.Root

    override public init() {
        let page = TwoDVoxelRaycastPage()
        guiRoot = WidgetGUI.Root(
            rootWidget: page)
        super.init()
        guiRoot.context = WidgetContext(defaultFontFamily: FontFamily(
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
        //self.guiRoot.context = context
        self.guiRoot.bounds = DRect(topLeft: DPoint2(0,0), size: window!.size)
        try self.guiRoot.layout()

        _ = self.window!.onResize(handleWindowResized)
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

    open func handleWindowResized(newSize: DSize2) {
        self.guiRoot.bounds.size = newSize
        do {
            try self.guiRoot.layout()
        } catch {
            print("Error during layout() guiRoot after updateSize.")
        }
    }

    open func render(deltaTime: Int) throws {
        //print("RENDER!!")
        try renderer!.clear(window!.background)
        try renderer!.beginFrame()
        try guiRoot.render(renderer: renderer!)
        try renderer!.endFrame()
        try self.window!.updateContent()
    }
}

public extension TwoDGraphicalApp {
    static let robotoFontFamily = FontFamily(name: "Roboto", faces: [
        //FontFace(path: "/home/adrian/.local/share/fonts/FiraCode-Light.ttf", weight: .Light, style: .Normal),
        FontFace(path: (Path.cwd/"Assets/fonts/Roboto-Regular.ttf").string, weight: .Regular, style: .Normal),
        //FontFace(path: "/home/adrian/.local/share/fonts/FiraCode-Medium.ttf", weight: .Medium, style: .Normal),
        FontFace(path: (Path.cwd/"Assets/fonts/Roboto-Bold.ttf").string, weight: .Bold, style: .Normal),
    ])
    static let defaultFontConfig = FontConfig(family: robotoFontFamily, size: 24, weight: .Regular, style: .Normal)
}

let app = TwoDGraphicalApp()

do {
    try app.start()
} catch {
    print("Error while running app", error)
}