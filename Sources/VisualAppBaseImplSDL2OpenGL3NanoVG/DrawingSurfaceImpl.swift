import VisualAppBase
import CSDL2
import CnanovgGL3
import GfxMath
import Drawing

public class SDL2OpenGL3NanoVGDrawingSurface: DrawingSurface {
  public var size: DSize2 = .zero
  public var resolution: Double = 0
  public let glContext: SDL_GLContext
  public let nvg: UnsafeMutablePointer<NVGcontext>

  public init(glContext: SDL_GLContext, nvg: UnsafeMutablePointer<NVGcontext>) {
    self.glContext = glContext
    self.nvg = nvg
  }

  public func getDrawingContext() -> DrawingContext {
    DrawingContext(backend: SDL2OpenGL3NanoVGDrawingBackend(surface: self))
  }
}