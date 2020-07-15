import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import Dispatch
import CustomGraphicsMath
import Path
import GL
import CSDL2

print("APP")

// TODO: create a subclass of App, DesktopApp which supports windows/screens which can support different resolutions --> renderContexts --> different text boundsSize
open class TwoDGraphicalApp: App<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {
    //public typealias Renderables = WidgetGUI.Renderables<System, Window, Renderer>
    open var window: Window?
    open var renderer: Renderer?
    //open var renderContext: RenderContext?

    open var guiRoot: WidgetGUI.Root

    private var cacheFramebuffer = GLMap.UInt()
    private var cacheTexture = GLMap.UInt()
    private var cacheDepthStencil = GLMap.UInt()
    private var screenVAO = GLMap.UInt()

    private var compositionShader = Shader(
        vertex: try! String(contentsOf: Path.cwd/"Sources/DemoApp/assets/guiVertex.glsl"),
        fragment: try! String(contentsOf: Path.cwd/"Sources/DemoApp/assets/guiFragment.glsl")
    )

    override public init() {
        let page = TwoDVoxelRaycastPage()
        guiRoot = WidgetGUI.Root(
            rootWidget: page)
        super.init()
        guiRoot.context = WidgetContext(
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

        glGenFramebuffers(1, &cacheFramebuffer)
        glBindFramebuffer(GLMap.FRAMEBUFFER, cacheFramebuffer)

        glGenTextures(1, &cacheTexture)
        glBindTexture(GLMap.TEXTURE_2D, cacheTexture)
        glTexImage2D(GLMap.TEXTURE_2D, 0, GLMap.RGB, GLMap.Size(window!.drawableSize.width), GLMap.Size(window!.drawableSize.height), 0, GLMap.RGB, GLMap.UNSIGNED_BYTE, nil)
        glTexParameteri(GLMap.TEXTURE_2D, GLMap.TEXTURE_MIN_FILTER, GLMap.LINEAR)
        glTexParameteri(GLMap.TEXTURE_2D, GLMap.TEXTURE_MAG_FILTER, GLMap.LINEAR)
        glBindTexture(GLMap.TEXTURE_2D, 0)

        glFramebufferTexture2D(GLMap.FRAMEBUFFER, GLMap.COLOR_ATTACHMENT0, GLMap.TEXTURE_2D, cacheTexture, 0)

        glGenRenderbuffers(1, &cacheDepthStencil)
        glBindRenderbuffer(GLMap.RENDERBUFFER, cacheDepthStencil)
        glRenderbufferStorage(GLMap.RENDERBUFFER, GLMap.DEPTH24_STENCIL8, GLMap.Size(window!.drawableSize.width), GLMap.Size(window!.drawableSize.height))
        glBindRenderbuffer(GLMap.RENDERBUFFER, 0)
        glFramebufferRenderbuffer(GLMap.FRAMEBUFFER, GLMap.DEPTH_STENCIL_ATTACHMENT, GLMap.RENDERBUFFER, cacheDepthStencil)

        if glCheckFramebufferStatus(GLMap.FRAMEBUFFER) != GLMap.FRAMEBUFFER_COMPLETE {
            print("Framebuffer not complete.")
        }

        glBindFramebuffer(GLMap.FRAMEBUFFER, 0)



        glGenVertexArrays(1, &screenVAO)
        glBindVertexArray(screenVAO)

        var screenVBO = GLMap.UInt()
        var vertices: [Float] = [
            -1, -1, 0.5,
            1, -1, 0.5,
            1, 1, 0.5,
            -1, -1, 0.5,
            1, 1, 0.5,
            -1, 1, 0.5
        ]
        glGenBuffers(1, &screenVBO)
        glBindBuffer(GLMap.ARRAY_BUFFER, screenVBO)
        glBufferData(GLMap.ARRAY_BUFFER, 3 * 6 * MemoryLayout<Float>.stride, vertices, GLMap.STATIC_DRAW)

        glVertexAttribPointer(0, 3, GLMap.FLOAT, false, GLMap.Size(3 * MemoryLayout<Float>.stride), nil)
        glEnableVertexAttribArray(0)

        glBindBuffer(GLMap.ARRAY_BUFFER, 0)

        glBindVertexArray(0)
        glBindTexture(GLMap.TEXTURE_2D, 0)

        try compositionShader.compile()
        
        _ = self.window!.onResize(handleWindowResized)
        _ = self.window!.onMouse(handleMouseEvent)
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

    open func handleWindowResized(newSize: DSize2) {
        self.guiRoot.bounds.size = newSize
        do {
            try self.guiRoot.layout()
        } catch {
            print("Error during layout() guiRoot after updateSize.")
        }
        glBindTexture(GLMap.TEXTURE_2D, cacheTexture)
        glTexImage2D(GLMap.TEXTURE_2D, 0, GLMap.RGB, GLMap.Size(window!.drawableSize.width), GLMap.Size(window!.drawableSize.height), 0, GLMap.RGB, GLMap.UNSIGNED_BYTE, nil)
        glBindTexture(GLMap.TEXTURE_2D, 0)
        glBindRenderbuffer(GLMap.RENDERBUFFER, cacheDepthStencil)
        glRenderbufferStorage(GLMap.RENDERBUFFER, GLMap.DEPTH24_STENCIL8, GLMap.Size(window!.drawableSize.width), GLMap.Size(window!.drawableSize.height))
        glBindRenderbuffer(GLMap.RENDERBUFFER, 0)
    }

    open func render(deltaTime: Int) throws {
        //print("RENDER!!")

        glBindFramebuffer(GLMap.FRAMEBUFFER, cacheFramebuffer)
        try renderer!.beginFrame()
        try renderer!.clear(window!.background)
        try guiRoot.render(renderer: renderer!)
        try renderer!.endFrame()

        glBindFramebuffer(GLMap.FRAMEBUFFER, 0)
        glViewport(0, 0, GLMap.Size(window!.drawableSize.width), GLMap.Size(window!.drawableSize.height))

        compositionShader.use()
        glBindTexture(GLMap.TEXTURE_2D, cacheTexture)
        glBindVertexArray(screenVAO)
        glDrawArrays(GLMap.TRIANGLES, 0, 6)

        try self.window!.updateContent()
    }
}

let app = TwoDGraphicalApp()

do {
    try app.start()
} catch {
    print("Error while running app", error)
}