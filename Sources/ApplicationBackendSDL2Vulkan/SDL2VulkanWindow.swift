import CVulkan
import Vulkan
import SDL2Vulkan
import ApplicationBackendSDL2
import DrawingVulkan
import GfxMath

public class SDL2VulkanWindow: SDL2BaseWindow {
  public init(initialSize: ISize2) {
    super.init(initialSize: initialSize, graphicsMode: .vulkan)
  }

  public func getVulkanDrawingSurface(instance: Vulkan.Instance) -> VulkanDrawingSurface {
    if self.graphicsMode != .vulkan {
      fatalError("a vulkan surface can only be created for windows which have been configured with graphicsMode: .vulkan")
    }
    if self.surface != nil {
      fatalError("can only use one surface per window")
    }

    var cVulkanSurface = VkSurfaceKHR(bitPattern: 0)
    if SDL_Vulkan_CreateSurface(sdlWindow, instance.pointer, &cVulkanSurface) != SDL_TRUE {
      fatalError("implement SDL errors! -> get the last sdl error")
    }
    let vulkanSurface = SurfaceKHR(instance: instance, surface: cVulkanSurface!)

    let surface = VulkanDrawingSurface(vulkanSurface: vulkanSurface, size: .zero, resolution: 0)
    self.surface = surface

    return surface
  }

  public func getVulkanInstanceExtensions() throws -> [String] {
    var opResult = SDL_FALSE
    var countArr: [UInt32] = [0]
    var result: [String] = []

    opResult = SDL_Vulkan_GetInstanceExtensions(sdlWindow, &countArr, nil)
    if opResult != SDL_TRUE {
      fatalError()
    }

    let count = Int(countArr[0])
    if count > 0 {
      let namesPtr = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: count)
      defer {
        namesPtr.deallocate()
      }

      opResult = SDL_Vulkan_GetInstanceExtensions(sdlWindow, &countArr, namesPtr)

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
}