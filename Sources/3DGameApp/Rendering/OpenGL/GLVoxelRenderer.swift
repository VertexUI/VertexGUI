import Foundation
import GL

public struct GLVoxelRenderer {

    private static let shaderProgram = ShaderProgram(

        vertex: vertexSource,
        
        fragment: fragmentSource
    )

    private static var vbo: GLMap.UInt = 0

    private static var vao: GLMap.UInt = 0

    public static func setup() {

        do {
            
            try shaderProgram.compile()

            glGenVertexArrays(1, &vao)
            glBindVertexArray(vao)

            glGenBuffers(1, &vbo)
            glBindBuffer(GLMap.ARRAY_BUFFER, vbo)

            glVertexAttribPointer(0, 2, GLMap.FLOAT, false, GLMap.Size(2 * MemoryLayout<GLMap.Float>.size), nil)
            glEnableVertexAttribArray(0)

            glBindVertexArray(0)
            glBindBuffer(GLMap.ARRAY_BUFFER, 0)

        } catch {

            print("Error in setup", error)
        }
    }

    public static func render(voxels: [Voxel]) {

        glBindVertexArray(vao)

        glBindBuffer(GLMap.ARRAY_BUFFER, vbo)
        glBufferData(GLMap.ARRAY_BUFFER, voxels.count * MemoryLayout<Float>.size * 2, voxels.flatMap { [Float($0.position.x), Float($0.position.y)] }, GLMap.DYNAMIC_DRAW)

        glDrawArrays(GLMap.TRIANGLES, 0, GLMap.Size(voxels.count))
    }
}

extension GLVoxelRenderer {

    private static let vertexSource = """
    #version 330 core

    layout (location = 0) in vec2 inPos;

    void main() {
        gl_Position = vec4(inPos, 1.0, 1.0);
    }
    """

    private static let fragmentSource = """
    #version 330 core

    out vec4 FragColor;

    void main() {

        FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
    """
}