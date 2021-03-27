#if USE_VULKAN
import GfxMath
import Vulkan

public class VulkanDrawingSurface: DrawingSurface {
  public var vulkanSurface: Vulkan.SurfaceKHR
  public var size: ISize2
  public var resolution: Double

  public init(vulkanSurface: Vulkan.SurfaceKHR, size: ISize2, resolution: Double) {
    self.vulkanSurface = vulkanSurface
    self.size = size
    self.resolution = resolution
  }

  public func getDrawingContext() -> DrawingContext {
    fatalError("don't use, change api")
  }
}
#endif