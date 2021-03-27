import CSDL2
import Drawing
import Application
import GfxMath
import Events
import CXShim
#if USE_VULKAN
import Vulkan
import CSDL2Vulkan
#endif

public class SDL2Window: Window {
  public var sdlWindow: OpaquePointer
  public var surface: DrawingSurface?

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


    /*let drawingBackend = SkiaCpuDrawingBackend(surface: surface)
    drawingBackend.drawLine(from: .zero, to: DVec2(options.initialSize), paint: Paint(color: nil, strokeWidth: 1, strokeColor: .blue))
    drawingBackend.drawRect(rect: DRect(min: DVec2(200, 200), max: DVec2(400, 400)), paint: Paint(color: .yellow))
    drawingBackend.drawCircle(center: DVec2(150, 150), radius: 100, paint: Paint(color: .green, strokeWidth: 1.0, strokeColor: .red))*/

    ApplicationBackendSDL2.windows[Int(SDL_GetWindowID(sdlWindow))] = self
  }

  func getCpuBufferDrawingSurface() -> CpuBufferDrawingSurface {
    if self.surface != nil {
      fatalError("can only use one surface per window")
    }

    let sdlSurface = SDL_GetWindowSurface(sdlWindow)

    let surface = CpuBufferDrawingSurface(size: size)
    surface.buffer = sdlSurface!.pointee.pixels.bindMemory(to: Int8.self, capacity: size.width * size.height * 4)
    self.surface = surface

    return surface
  }

  func updateSurface() {
    if let surface = surface as? CpuBufferDrawingSurface {
      let sdlSurface = SDL_GetWindowSurface(sdlWindow)
      surface.size = size
      surface.buffer = sdlSurface!.pointee.pixels.bindMemory(to: Int8.self, capacity: size.width * size.height * 4)
    }
  }

  /**
  only necessary if you are using CpuBufferDrawingSurface
  */
  public func swap() {
    SDL_UpdateWindowSurface(sdlWindow)
  }

  #if USE_VULKAN
  public func getVulkanDrawingSurface(instance: Vulkan.Instance) -> VulkanDrawingSurface {
    if self.surface != nil {
      fatalError("can only use one surface per window")
    }

    var cVulkanSurface = VkSurfaceKHR(bitPattern: 0)
    if SDL_Vulkan_CreateSurface(window, instance.pointer, &cVulkanSurface) != SDL_TRUE {
      fatalError("implement SDL errors! -> get the last sdl error")
    }
    let vulkanSurface = SurfaceKHR(instance: instance, surface: surface!)

    let surface = VulkanDrawingSurface(vulkanSurface: vulkanSurface, size: .zero, resolution: 0)
    self.surface = surface

    return surface
  }

  public func getVulkanInstanceExtensions() throws -> [String] {
    var opResult = SDL_FALSE
    var countArr: [UInt32] = [0]
    var result: [String] = []

    opResult = SDL_Vulkan_GetInstanceExtensions(window, &countArr, nil)
    if opResult != SDL_TRUE {
      fatalError()
    }

    let count = Int(countArr[0])
    if count > 0 {
      let namesPtr = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: count)
      defer {
        namesPtr.deallocate()
      }

      opResult = SDL_Vulkan_GetInstanceExtensions(window, &countArr, namesPtr)

      if opResult == SDL_TRUE {
        for i in 0..<count {
          let namePtr = namesPtr[i]
          let newName = String(cString: namePtr!)
          result.append(newName)
        }
      }
    }

    return result
  }
  #endif

  public func notifySizeChanged() {
    updateSurface()
    sizeChanged.send(size)
  }

  public func close() {
    SDL_DestroyWindow(sdlWindow)
  }
}