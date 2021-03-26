import CSDL2
import Drawing
import Application
import GfxMath
import Events
import CXShim

public class SDL2Window: Window {
  public var sdlWindow: OpaquePointer
  public var surface: CpuBufferDrawingSurface

  public var size: ISize2 {
    var width: Int32 = 0
    var height: Int32 = 0
    SDL_GetWindowSize(sdlWindow, &width, &height)
    return ISize2(Int(width), Int(height))
  }

  // TODO: instead use property wrapper on size so that can do: $size.sink
  public let sizeChanged = PassthroughSubject<ISize2, Never>()

  public required init(initialSize: DSize2) {
    SDL_Init(SDL_INIT_VIDEO)

    let size = ISize2(initialSize)

    sdlWindow = SDL_CreateWindow(
      "",
      0,
      0,
      Int32(initialSize.width),
      Int32(initialSize.height),
      SDL_WINDOW_RESIZABLE.rawValue)

    let sdlSurface = SDL_GetWindowSurface(sdlWindow)

    surface = CpuBufferDrawingSurface(size: size)
    surface.buffer = sdlSurface!.pointee.pixels.bindMemory(to: Int8.self, capacity: size.width * size.height * 4)
    /*let drawingBackend = SkiaCpuDrawingBackend(surface: surface)
    drawingBackend.drawLine(from: .zero, to: DVec2(options.initialSize), paint: Paint(color: nil, strokeWidth: 1, strokeColor: .blue))
    drawingBackend.drawRect(rect: DRect(min: DVec2(200, 200), max: DVec2(400, 400)), paint: Paint(color: .yellow))
    drawingBackend.drawCircle(center: DVec2(150, 150), radius: 100, paint: Paint(color: .green, strokeWidth: 1.0, strokeColor: .red))*/

    ApplicationBackendSDL2.windows[Int(SDL_GetWindowID(sdlWindow))] = self
  }

  func updateSurface() {
    print("UPDATE SURFACE SIZE", size)
    let sdlSurface = SDL_GetWindowSurface(sdlWindow)
    surface = CpuBufferDrawingSurface(size: size)
    surface.buffer = sdlSurface!.pointee.pixels.bindMemory(to: Int8.self, capacity: size.width * size.height * 4)
  }

  public func swap() {
    SDL_UpdateWindowSurface(sdlWindow)
  }

  public func notifySizeChanged() {
    updateSurface()
    sizeChanged.send(size)
  }

  public func close() {
    SDL_DestroyWindow(sdlWindow)
  }
}