import CSDL2
import CnanovgGL3
import GfxMath
import Foundation
import GL
import Path
import VisualAppBase
import WidgetGUI

open class SDL2OpenGL3NanoVGWindow: Window {
  public var sdlWindow: OpaquePointer
  public var glContext: SDL_GLContext
  public var nvg: UnsafeMutablePointer<NVGcontext>
  public let drawingSurface: SDL2OpenGL3NanoVGDrawingSurface
  private var drawingContext: DrawingContext?

  private var _id: Int = -1
  override open var id: Int {
    _id
  }

  public var pixelRatio: Float {
    return Float(drawableSize.width / size.width)
  }

  public required init(options: Options) throws {
    /* sdlWindow = try SDL.SDLWindow(title: "SDLDemo",
                frame: (x: .centered, y: .centered, width: Int(size.width), height: Int(size.height)),
                options: [.resizable, .Visible, .opengl, .allowRetina])*/

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

    if options.initialVisibility == .Hidden {
      flags |= SDL_WINDOW_HIDDEN.rawValue
    }

    sdlWindow = SDL_CreateWindow(
      options.title ?? "",
      x,
      y,
      Int32(options.initialSize.width),
      Int32(options.initialSize.height),
      flags
    )

    if sdlWindow == nil {
      throw WindowError.SDLWindowCreationFailed
    }

    SDL_SetWindowBordered(sdlWindow, SDL_bool(1))

    glContext = SDL_GL_CreateContext(sdlWindow)
    SDL_GL_MakeCurrent(sdlWindow, glContext)

    nvg = nvgCreateGL3(
      Int32(NVG_ANTIALIAS.rawValue | NVG_STENCIL_STROKES.rawValue | NVG_DEBUG.rawValue))

    drawingSurface = SDL2OpenGL3NanoVGDrawingSurface(glContext: glContext, nvg: nvg)

    try super.init(options: options)

    _ = self.onSizeChanged { [unowned self] _ in
      drawingSurface.size = drawableSize 
      drawingSurface.resolution = resolution
    }

    _id = Int(SDL_GetWindowID(sdlWindow))
    
    SDL2OpenGL3NanoVGSystem.windows[id] = self

    invalidateSize()
    print("RESOLUTION", resolution)
    invalidatePosition()
    invalidateInputFocus()
  }

  override open func readSize() -> DSize2 {
    var width: Int32 = 0
    var height: Int32 = 0
    SDL_GetWindowSize(sdlWindow, &width, &height)
    return DSize2(Double(width), Double(height))
  }

  override open func readDrawableSize() -> DSize2 {
    var width: Int32 = 0
    var height: Int32 = 0
    SDL_GL_GetDrawableSize(sdlWindow, &width, &height)
    return DSize2(Double(width), Double(height))
  }

  override open func readPosition() -> DPoint2 {
    var x: Int32 = 0
    var y: Int32 = 0
    SDL_GetWindowPosition(sdlWindow, &x, &y)
    return DPoint2(Double(x), Double(y))
  }

  override open func readVisibility() -> Window.Visibility {
    let flags = SDL_GetWindowFlags(sdlWindow)
    if flags & SDL_WINDOW_SHOWN.rawValue == SDL_WINDOW_SHOWN.rawValue {
      return .Visible
    } else if flags & SDL_WINDOW_HIDDEN.rawValue == SDL_WINDOW_HIDDEN.rawValue {
      return .Hidden
    } else {
      fatalError("sdl flag shown nor sdl flag hidden are present in window flags")
    }
  }

  override open func readInputFocus() -> Bool {
    let flags = SDL_GetWindowFlags(sdlWindow)
    return flags & SDL_WINDOW_INPUT_FOCUS.rawValue == SDL_WINDOW_INPUT_FOCUS.rawValue
  }

  override open func applySize(_ newSize: DSize2) {
    SDL_SetWindowSize(sdlWindow, Int32(newSize.width), Int32(newSize.height))
  }

  override open func applyPosition(_ newPosition: DPoint2) {
    SDL_SetWindowPosition(sdlWindow, Int32(newPosition.x), Int32(newPosition.y))
  }

  override open func applyVisibility(_ newVisibility: Window.Visibility) {
    switch newVisibility {
    case .Visible:
      SDL_ShowWindow(sdlWindow)
    case .Hidden:
      SDL_HideWindow(sdlWindow)
    }
  }

  override open func applyInputFocus(_ newFocus: Bool) {
    if newFocus {
      SDL_SetWindowInputFocus(sdlWindow)
    }
  }

  override open func makeCurrent() {
    SDL_GL_MakeCurrent(sdlWindow, glContext)
  }

  override open func getDrawingContext() -> DrawingContext {
    if drawingContext == nil {
      drawingContext = drawingSurface.getDrawingContext()
    }
    return drawingContext!
  }

  override open func clear() {
    GL.glViewport(0, 0, GLMap.Size(drawableSize.width), GLMap.Size(drawableSize.height))
    GL.glClearColor(options.background.glR, options.background.glG, options.background.glB, options.background.glA)
    GL.glClear(GLMap.COLOR_BUFFER_BIT)
  }

  override open func updateContent() {
    SDL_GL_SwapWindow(sdlWindow)
  }

  override open func destroySelf() {
    // TODO: need to destroy those two contexts here?
    nvgDeleteGL3(nvg)
    SDL_GL_DeleteContext(glContext)
    SDL_DestroyWindow(sdlWindow)
    print("DESTROYED WINDOW")
    SDL2OpenGL3NanoVGSystem.windows.removeValue(forKey: id)
  }
  
  deinit {
    print("DEINITIALIZED WINDOW")
  }
}

extension SDL2OpenGL3NanoVGWindow {
  public enum WindowError: Error {
    case SDLWindowCreationFailed
  }
}