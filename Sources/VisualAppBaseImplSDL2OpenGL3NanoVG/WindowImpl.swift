import WidgetGUI
import Foundation
import CSDL2
import CnanovgGL3
//import Cnanovg

//import Cnanovg.gl
import GL
import Path
import CustomGraphicsMath
import VisualAppBase

/*
public typealias UnregisterCallback = () throws -> Void
public typealias OnFrameCallback = (_ deltaTime: UInt32, _ unregister: UnregisterCallback) -> Void
public typealias OnResizeCallback = (_ newSize: DSize2, _ unregister: UnregisterCallback) throws -> Void
public typealias OnMouseCallback = (_ event: MouseEvent, _ unregister: UnregisterCallback) -> Void
*/

open class SDL2OpenGL3NanoVGWindow: Window {
    public var sdlWindow: OpaquePointer
    public var glContext: SDL_GLContext 
    public var nvg: UnsafeMutablePointer<NVGcontext>

    override open var id: Int {
        get {
            return Int(SDL_GetWindowID(sdlWindow))
        }
    }

    public var drawableSize: DSize2 = DSize2(0, 0)
    public var pixelRatio: Float {
        get {
            return Float(drawableSize.width / size.width)
        }
    }

    public required init(background: Color, size: DSize2) throws {
       /* sdlWindow = try SDL.SDLWindow(title: "SDLDemo",
                frame: (x: .centered, y: .centered, width: Int(size.width), height: Int(size.height)),
                options: [.resizable, .shown, .opengl, .allowRetina])*/
        sdlWindow = SDL_CreateWindow(
            "WOW A TITLE",
            Int32(SDL_WINDOWPOS_CENTERED_MASK),
            Int32(SDL_WINDOWPOS_CENTERED_MASK),
            Int32(size.width),
            Int32(size.height),
            SDL_WINDOW_OPENGL.rawValue | SDL_WINDOW_RESIZABLE.rawValue | SDL_WINDOW_ALLOW_HIGHDPI.rawValue)

        SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 		8);
        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 		1);
        SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 		1);
        SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 		8);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3)
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, Int32(SDL_GL_CONTEXT_PROFILE_CORE.rawValue))

        glContext = SDL_GL_CreateContext(sdlWindow)
        SDL_GL_MakeCurrent(sdlWindow, glContext)



        
        //shader = Shader(vertexSource: vertexSource!, fragmentSource: fragmentSource!)
        //try shader.compile()
        //SDL_GL_SetSwapInterval(1)

        //GL.glGenBuffers(1, &VBO)
        //GL.glBindBuffer(GLMap.ARRAY_BUFFER, VBO)
        //GL.glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<GLMap.Float>.stride * vertices.count, vertices, GLMap.STATIC_DRAW)

        //glVertexAttribPointer(0, 3, GLMap.FLOAT, false, Int32(3 * MemoryLayout<GLMap.Float>.stride), UnsafeRawPointer(bitPattern: 0))
        //glEnableVertexAttribArray(0)



        //print("NVG", nvgCreateGL3(Int32(NVG_DEBUG.rawValue)))
        nvg = nvgCreateGL3(Int32(NVG_ANTIALIAS.rawValue | NVG_STENCIL_STROKES.rawValue | NVG_DEBUG.rawValue))

        print("ERROR?: ", GL.glGetError())

        try super.init(background: background, size: size)

        try updateSize()

        SDL2OpenGL3NanoVGSystem.windows[id] = self
    }

    deinit {
        SDL_GL_DeleteContext(glContext)
        SDL_DestroyWindow(sdlWindow)
    }

    override open func updateSize() throws {
        var newWidth: Int32 = 0
        var newHeight: Int32 = 0
        SDL_GetWindowSize(sdlWindow, &newWidth, &newHeight)
        size.width = Double(newWidth)
        size.height = Double(newHeight)
        SDL_GL_GetDrawableSize(sdlWindow, &newWidth, &newHeight)
        drawableSize.width = Double(newWidth)
        drawableSize.height = Double(newHeight)
        //SDL_GL_MakeCurrent(sdlWindow, glContext)
        //glViewport(x: 0, y: 0, width: GLMap.Size(drawableSize.width), height: GLMap.Size(drawableSize.height))
        try super.updateSize()
    }

    override open func updateContent() {
        SDL_GL_SwapWindow(sdlWindow)
    } 
}