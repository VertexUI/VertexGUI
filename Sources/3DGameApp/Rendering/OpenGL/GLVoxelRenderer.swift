import Foundation
import GL
import CustomGraphicsMath

public struct Vertex {

    public var position: DVec3

    public var normal: DVec3

    public init(_ position: DVec3, _ normal: DVec3) {

        self.position = position

        self.normal = normal
    }
}

public struct GLVoxelRenderer {

    private static let shaderProgram = ShaderProgram(

        vertex: vertexSource,
        
        fragment: fragmentSource
    )

    private static var vbo: GLMap.UInt = 0

    private static var vao: GLMap.UInt = 0

    private static var ebo: GLMap.UInt = 0

    private static var baseVertices: [Vertex] = [

        // top
        Vertex(DVec3(-0.5, 0.5, 0.5), DVec3(0, 1, 0)),

        Vertex(DVec3(0.5, 0.5, 0.5), DVec3(0, 1, 0)),

        Vertex(DVec3(0.5, 0.5, -0.5), DVec3(0, 1, 0)),
        
        Vertex(DVec3(-0.5, 0.5, -0.5), DVec3(0, 1, 0)),

        // front
        Vertex(DVec3(-0.5, -0.5, 0.5), DVec3(0, 0, 1)),

        Vertex(DVec3(0.5, -0.5, 0.5), DVec3(0, 0, 1)),

        Vertex(DVec3(0.5, 0.5, 0.5), DVec3(0, 0, 1)),

        Vertex(DVec3(-0.5, 0.5, 0.5), DVec3(0, 0, 1))
    ]

    private static var indices: [GLMap.UInt] = [

        // top
        0, 1, 2,

        0, 2, 3,

        // front
        4, 5, 6,

        4, 6, 7
    ]

    private static let worldTransformation = AnyMatrix4<GLMap.Float>([
        
        0.4, 0, 0.9, 0,

        0, 1, 0, 0,

        0, 0, 1, 0,

        0, 0, 0, 1
    ])

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

            glVertexAttribPointer(0, 4, GLMap.FLOAT, false, GLMap.Size(7 * MemoryLayout<GLMap.Float>.size), UnsafeRawPointer(bitPattern: 0))
            glEnableVertexAttribArray(0)

            glVertexAttribPointer(1, 3, GLMap.FLOAT, false, GLMap.Size(7 * MemoryLayout<GLMap.Float>.size), UnsafeRawPointer(bitPattern: MemoryLayout<GLMap.Float>.size * 3))
            glEnableVertexAttribArray(1)

            glBindVertexArray(0)
            glBindBuffer(GLMap.ARRAY_BUFFER, 0)
            glBindBuffer(GLMap.ELEMENT_ARRAY_BUFFER, 0)

        } catch {

            print("Error in setup", error)
        }
    }

    private static func getAxes(pitch: Double, yaw: Double) -> (x: DVec3, y: DVec3, z: DVec3) {

        let x = DVec3(x: 1, y: 0, z: tan(yaw))

        let y = DVec3(x: 0, y: 1, z: tan(pitch)).normalized()

        let z = DVec3(x: tan(yaw), y: tan(pitch), z: 1).normalized()

        return (x, y, z)
    }

    public static func render(voxels: [Voxel]) {

        shaderProgram.use()

        glBindVertexArray(vao)

        glBindBuffer(GLMap.ARRAY_BUFFER, vbo)

        let axes = getAxes(pitch: 45, yaw: 45)

        let worldTransformation = AnyMatrix4<GLMap.Float>([

            axes.x.x, axes.x.y, axes.x.z, 0,

            axes.y.x, axes.y.y, axes.y.z, 0,

            axes.z.x, axes.z.y, axes.z.z, 0,

            0, 0, 0, 1

        ].map(Float.init))

        var bufferData = [GLMap.Float]()

        for voxel in voxels {

            for vertex in baseVertices {

                var position = AnyVector4<Float>((vertex.position + voxel.position).elements.map(Float.init) + [1])

                position = AnyVector4(try! worldTransformation.matmul(position).elements)

                let normal = try! worldTransformation.matmul(AnyVector4<Float>(vertex.normal.elements.map(Float.init) + [1]))

                bufferData.append(contentsOf: position.elements)

                bufferData.append(contentsOf: normal.elements[..<3])
            }
        }

        /*let vertices = voxels.flatMap { voxel in

            baseVertices.flatMap { vertex -> [Float] in

                let vertex4 = AnyVector4<Float>((vertex + voxel.position).elements.map(Float.init) + [1])

                return (worldTransformation * vertex4).elements[..<3].map { Float($0) } }
        }*/

        glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<Float>.size * bufferData.count, bufferData, GLMap.STATIC_DRAW)

        // CONTINUE READING: https://www.scratchapixel.com/lessons/3d-basic-rendering/computing-pixel-coordinates-of-3d-point/mathematics-computing-2d-coordinates-of-3d-points

        glDrawElements(GLMap.TRIANGLES, GLMap.Size(indices.count * voxels.count), GLMap.UNSIGNED_INT, nil)

        glBindVertexArray(0)
    }
}

extension GLVoxelRenderer {

    private static let vertexSource = """
    #version 330 core

    layout (location = 0) in vec4 inPos;

    layout (location = 1) in vec3 inNormal;

    out vec3 Normal;

    void main() {
        
        gl_Position = inPos;

        Normal = inNormal;
    }
    """

    private static let fragmentSource = """
    #version 330 core

    in vec3 Normal;

    out vec4 FragColor;

    void main() {

        FragColor = dot(Normal, vec3(0, 1, 0)) * vec4(1.0, 1.0, 1.0, 1.0);
    }
    """
}