import Foundation
import GL

public class FoodShaderProgram: ShaderProgram {    
    public internal(set) var uniformPerspectiveMinLocation = GLMap.Int()
    public internal(set) var uniformPerspectiveMaxLocation = GLMap.Int()
    
    public init() {
        super.init(
            vertex: try! String(contentsOf: Bundle.module.path(forResource: "FoodBlobVertexShader", ofType: "glsl")!),
            fragment: try! String(contentsOf: Bundle.module.path(forResource: "BlobFragmentShader", ofType: "glsl")!)
        )
    }

    override public func compile() throws {
        try super.compile()

        uniformPerspectiveMinLocation = glGetUniformLocation(id!, "perspectiveMin")
        uniformPerspectiveMaxLocation = glGetUniformLocation(id!, "perspectiveMax")
    }
}