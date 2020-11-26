import Foundation
import VisualAppBase
import GL
import GLUtils
import GfxMath

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

  var imageTexture = GLMap.UInt()

  override public init(context: ApplicationContext) {
    super.init(context: context)
   
    try! imageShader.compile()

    imageVao.attributes = [
      GLVertexArray.ContiguousAttributes(buffer: imageVbo, attributes: [
        GLVertexAttribute(location: 0, dataType: Float.self, length: 2),
        GLVertexAttribute(location: 1, dataType: Float.self, length: 2),
      ])
    ]
    imageVao.setup()
    imageVao.bind()

    glGenTextures(1, &imageTexture)

    //imageVbo.bind(.arrayBuffer)
    //imageVbo.store(imageVertices)

    GLVertexArray.unbind()
  }

  override open func renderLeaf(node: RenderObject, with backendRenderer: Renderer) {
    if let node = node as? VideoRenderObject {
      if let frameData = node.stream.getCurrentFrame() {
        //glViewport(0, 0, 600, 600)
        imageShader.use()
        //imageShader.setUniform()
        imageVao.bind()

        let relativeSize = FVec2(node.bounds.size) / FVec2(context.window.size)
        let relativePosition = FVec2(node.bounds.min) / FVec2(context.window.size)

        let glPosition = (FVec2(relativePosition.x, 1 - relativePosition.y)) * 2 - FVec2(1, 1)
        let glSize = relativeSize * 0.5

        let glTopLeft = glPosition
        let glTopRight = glPosition + FVec2(glSize.x, 0)
        let glBottomRight = glPosition + glSize * FVec2(1, -1)
        let glBottomLeft = glPosition + FVec2(0, -glSize.y)

        let vertices = [
          glBottomLeft, FVec2(-1, -1),
          glBottomRight, FVec2(1, -1),
          glTopRight, FVec2(1, 1),
          glBottomLeft, FVec2(-1, -1),
          glTopRight, FVec2(1, 1),
          glTopLeft, FVec2(-1, 1)
        ].flatMap { $0.elements }

        imageVbo.bind(.arrayBuffer)
        imageVbo.store(vertices)

        glBindTexture(GLMap.TEXTURE_2D, imageTexture)
        glTexImage2D(
          GLMap.TEXTURE_2D,
          0,
          GLMap.RGB,
          GLMap.Size(node.stream.size.width),
          GLMap.Size(node.stream.size.height),
          0,
          GLMap.RGB,
          GLMap.UNSIGNED_BYTE,
          frameData.baseAddress)
        frameData.deallocate()
        glGenerateMipmap(GLMap.TEXTURE_2D)

        glDrawArrays(GLMap.TRIANGLES, 0, 6)
      }
      return
    }
    
    super.renderLeaf(node: node, with: backendRenderer)
  }
}