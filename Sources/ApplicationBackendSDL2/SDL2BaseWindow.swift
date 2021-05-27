import CSDL2
import Drawing
import Application
import GfxMath
import Events
import OpenCombine

open class SDL2BaseWindow: Window {
  public var sdlWindow: OpaquePointer
  public let graphicsMode: GraphicsMode
  public var surface: DrawingSurface?

  public var size: ISize2 {
    var width: Int32 = 0
    var height: Int32 = 0
    SDL_GetWindowSize(sdlWindow, &width, &height)
    return ISize2(Int(width), Int(height))
  }

  // TODO: instead use property wrapper on size so that can do: $size.sink
  public let sizeChanged = PassthroughSubject<ISize2, Never>()
  public let inputEventPublisher = PassthroughSubject<WindowInputEvent, Never>()

  public init(initialSize: ISize2, graphicsMode: GraphicsMode = .cpu) {
    SDL_Init(SDL_INIT_VIDEO)
    self.graphicsMode = graphicsMode

    var flags = SDL_WINDOW_RESIZABLE.rawValue
    if graphicsMode == .vulkan {
      flags = flags | SDL_WINDOW_VULKAN.rawValue
    }

    sdlWindow = SDL_CreateWindow(
      "",
      0,
      0,
      Int32(initialSize.width),
      Int32(initialSize.height),
      flags)


    /*let drawingBackend = SkiaCpuDrawingBackend(surface: surface)
    drawingBackend.drawLine(from: .zero, to: DVec2(options.initialSize), paint: Paint(color: nil, strokeWidth: 1, strokeColor: .blue))
    drawingBackend.drawRect(rect: DRect(min: DVec2(200, 200), max: DVec2(400, 400)), paint: Paint(color: .yellow))
    drawingBackend.drawCircle(center: DVec2(150, 150), radius: 100, paint: Paint(color: .green, strokeWidth: 1.0, strokeColor: .red))*/

    ApplicationBackendSDL2.windows[Int(SDL_GetWindowID(sdlWindow))] = self
  }

  /**
  only necessary if you are using CpuBufferDrawingSurface
  */
  open func swap() {}

  open func updateSurface() {}

  public func notifySizeChanged() {
    updateSurface()
    sizeChanged.send(size)
  }

  public func close() {
    SDL_DestroyWindow(sdlWindow)
  }

  public enum GraphicsMode {
    case cpu, openGL, vulkan
  }
}