import SDL2
import Drawing
import Application
import GfxMath
import Events
import OpenCombine

public class SDL2Window: SDL2BaseWindow {
  public init(initialSize: ISize2) {
    super.init(initialSize: initialSize, graphicsMode: .cpu)
  }

  public func getCpuBufferDrawingSurface() -> CpuBufferDrawingSurface {
    if self.graphicsMode != .cpu {
      fatalError("a cpu surface can only be created for windows which have been configured with graphicsMode: .cpu")
    }
    if self.surface != nil {
      fatalError("can only use one surface per window")
    }

    let sdlSurface = SDL_GetWindowSurface(sdlWindow)

    let surface = CpuBufferDrawingSurface(size: size)
    surface.buffer = UnsafeMutableBufferPointer(
      start: sdlSurface!.pointee.pixels.bindMemory(
        to: UInt8.self, capacity: size.width * size.height * 4),
      count: size.width * size.height * 4)
    self.surface = surface

    return surface
  }

  override public func updateSurface() {
    if let surface = surface as? CpuBufferDrawingSurface {
      let sdlSurface = SDL_GetWindowSurface(sdlWindow)
      surface.size = size
      surface.buffer = UnsafeMutableBufferPointer(
        start: sdlSurface!.pointee.pixels.bindMemory(
          to: UInt8.self, capacity: size.width * size.height * 4),
        count: size.width * size.height * 4)
    }
  }

  override public func swap() {
    SDL_UpdateWindowSurface(sdlWindow)
  }
}