import Foundation
import VisualAppBase
import GL
import GLUtils

open class SDL2OpenGL3NanoVGRenderObjectTreeSliceRenderer: RenderObjectTreeSliceRenderer {
  private let imageShader = Shader(
    vertex: try! String(contentsOf: Bundle.module.url(forResource: "imageVertex", withExtension: "glsl")!),
    fragment: try! String(contentsOf:  Bundle.module.url(forResource: "imageFragment", withExtension: "glsl")!))

  override public init(context: ApplicationContext) {
    super.init(context: context)
    try! imageShader.compile()
  }

  override open func renderLeaf(node: RenderObject, with backendRenderer: Renderer) {
    if let node = node as? VideoRenderObject {
      
      return
    }
    
    super.renderLeaf(node: node, with: backendRenderer)
  }
}