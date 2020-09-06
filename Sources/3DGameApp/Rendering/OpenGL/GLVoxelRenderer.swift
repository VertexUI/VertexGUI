import Foundation
import GL
import CustomGraphicsMath

public struct GLVoxelRenderer {

    private static let shaderProgram = ShaderProgram(

        vertex: vertexSource,
        
        fragment: fragmentSource
    )

    private static var vbo: GLMap.UInt = 0

    private static var vao: GLMap.UInt = 0

    private static var ebo: GLMap.UInt = 0

    private static var baseVertices: [DVec3] = [

        // One Top Triangle
        DVec3(-0.5, 0.5, 0.5),

        DVec3(0.5, 0.5, 0.5),

        DVec3(0.5, 0.5, -0.5),

        // front
        DVec3(-0.5, -0.5, 0.5),

        DVec3(0.5, -0.5, 0.5),

        DVec3(0.5, 0.5, 0.5),

        DVec3(-0.5, 0.5, 0.5)
    ]

    private static var indices: [GLMap.UInt] = [

        // top
        0, 1, 2,

        // front
        3, 4, 5,

        3, 5, 6
    ]

    public static func setup() {

        do {
            
            try shaderProgram.compile()

            glGenVertexArrays(1, &vao)
            glBindVertexArray(vao)

            glGenBuffers(1, &vbo)
            glBindBuffer(GLMap.ARRAY_BUFFER, vbo)

            glGenBuffers(1, &ebo)
            glBindBuffer(GLMap.ELEMENT_ARRAY_BUFFER, ebo)
            glBufferData(GLMap.ELEMENT_ARRAY_BUFFER, MemoryLayout<GLMap.UInt>.size * indices.count, indices, GLMap.STATIC_DRAW)

            glVertexAttribPointer(0, 3, GLMap.FLOAT, false, GLMap.Size(3 * MemoryLayout<GLMap.Float>.size), nil)
            glEnableVertexAttribArray(0)

            glBindVertexArray(0)
            glBindBuffer(GLMap.ARRAY_BUFFER, 0)
            glBindBuffer(GLMap.ELEMENT_ARRAY_BUFFER, 0)

        } catch {

            print("Error in setup", error)
        }
    }

    public static func render(voxels: [Voxel]) {

        glBindVertexArray(vao)

        glBindBuffer(GLMap.ARRAY_BUFFER, vbo)

        let vertices = voxels.flatMap { voxel in

            baseVertices.flatMap { ($0 + voxel.position).elements.map(Float.init) }
        }

        glBufferData(GLMap.ARRAY_BUFFER, voxels.count * MemoryLayout<Float>.size * baseVertices.count * 3, vertices, GLMap.DYNAMIC_DRAW)

        // CONTINUE READING: https://www.scratchapixel.com/lessons/3d-basic-rendering/computing-pixel-coordinates-of-3d-point/mathematics-computing-2d-coordinates-of-3d-points

        glDrawElements(GLMap.TRIANGLES, GLMap.Size(indices.count * voxels.count), GLMap.UNSIGNED_INT, nil)
    }
}

extension GLVoxelRenderer {

    private static let vertexSource = """
    #version 330 core

    layout (location = 0) in vec3 inPos;

    void main() {
        gl_Position = vec4(inPos, 1.0);
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