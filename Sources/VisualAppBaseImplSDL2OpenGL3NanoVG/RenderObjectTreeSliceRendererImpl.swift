import Foundation
import VisualAppBase
import GL
import GLUtils

open class SDL2OpenGL3NanoVGRenderObjectTreeSliceRenderer: RenderObjectTreeSliceRenderer {
  private let imageShader = Shader(
    vertex: try! String(contentsOf: Bundle.module.url(forResource: "imageVertex", withExtension: "glsl")!),
    fragment: try! String(contentsOf:  Bundle.module.url(forResource: "imageFragment", withExtension: "glsl")!))

  var imageVao = GLVertexArray()
  var imageVbo = GLBuffer()
  let imageVertices: [Float] = [
    -1, -1,
    1, -1,
    1, 1,
    -1, -1,
    1, 1,
    -1, 1
  ]

  override public init(context: ApplicationContext) {
    super.init(context: context)
   
    try! imageShader.compile()

    imageVao.attributes = [
      GLVertexArray.ContiguousAttributes(buffer: imageVbo, attributes: [
        GLVertexAttribute(location: 0, dataType: Float.self, length: 2)
      ])
    ]
    imageVao.setup()
    imageVao.bind()

    imageVbo.setup()
    imageVbo.bind(.arrayBuffer)
    imageVbo.store(imageVertices)

    GLVertexArray.unbind()
  }

  override open func renderLeaf(node: RenderObject, with backendRenderer: Renderer) {

    /*if let node = node as? VideoRenderObject {
      glViewport(0, 0, 100, 100)
      imageShader.use()
      imageVao.bind()
      //glDrawArrays(GLMap.TRIANGLES, 0, 6)
      return
    }*/
    
    super.renderLeaf(node: node, with: backendRenderer)
  }
}