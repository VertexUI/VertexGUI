import CSDL2
import CnanovgGL3
import CustomGraphicsMath
import Foundation
import GL
import Path
import VisualAppBase
import WidgetGUI

open class SDL2OpenGL3NanoVGWindow: Window {
  public var sdlWindow: OpaquePointer
  public var glContext: SDL_GLContext
  public var nvg: UnsafeMutablePointer<NVGcontext>

  override open var id: Int {
    return Int(SDL_GetWindowID(sdlWindow))
  }

  public var pixelRatio: Float {
    return Float(drawableSize.width / size.width)
  }

  public required init(options: Options) throws {
    /* sdlWindow = try SDL.SDLWindow(title: "SDLDemo",
                frame: (x: .centered, y: .centered, width: Int(size.width), height: Int(size.height)),
                options: [.resizable, .shown, .opengl, .allowRetina])*/

    SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8)
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1)
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 8)
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3)
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, Int32(SDL_GL_CONTEXT_PROFILE_CORE.rawValue))
    SDL_GL_SetSwapInterval(1)

    let x: Int32
    let y: Int32

    switch options.initialPosition {
    case .Centered:
      x = Int32(SDL_WINDOWPOS_CENTERED_MASK)
      y = Int32(SDL_WINDOWPOS_CENTERED_MASK)
    case let .Defined(point):
      x = Int32(point.x)
      y = Int32(point.y)
    }

    var flags: UInt32 = SDL_WINDOW_OPENGL.rawValue | SDL_WINDOW_RESIZABLE.rawValue | SDL_WINDOW_ALLOW_HIGHDPI.rawValue

    if options.borderless {
      flags |= SDL_WINDOW_BORDERLESS.rawValue
    }

    sdlWindow = SDL_CreateWindow(
      options.title ?? "",
      x,
      y,
      Int32(options.initialSize.width),
      Int32(options.initialSize.height),
      flags
    )

    glContext = SDL_GL_CreateContext(sdlWindow)
    SDL_GL_MakeCurrent(sdlWindow, glContext)

    nvg = nvgCreateGL3(
      Int32(NVG_ANTIALIAS.rawValue | NVG_STENCIL_STROKES.rawValue | NVG_DEBUG.rawValue))

    try super.init(options: options)

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
    try super.updateSize()
  }

  override open func updateContent() {
    SDL_GL_SwapWindow(sdlWindow)
  }

  override open func close() {
    nvgDeleteGL3(nvg)
    SDL_GL_DeleteContext(glContext)
    SDL_DestroyWindow(sdlWindow)
    onClose.invokeHandlers(Void())
  }

  open func makeCurrent() {
    SDL_GL_MakeCurrent(sdlWindow, glContext)
  }
}
