import GL

public struct ShaderError: Error {
    let info: String

    init(_ info: String) {
        self.info = info
    }
}

open class ShaderProgram {
    public let vertexSource: String
    public let fragmentSource: String
    public var id: GLMap.UInt?

    public init(vertex vertexSource: String, fragment fragmentSource: String) {
        self.vertexSource = vertexSource
        self.fragmentSource = fragmentSource
    }

    deinit {
        if let id = id {
            glDeleteProgram(id)
        }
    }

    /// compiles and links the shaders
    open func compile() throws {
        let vertexShader = glCreateShader(GLMap.VERTEX_SHADER)
        withUnsafePointer(to: vertexSource) { ptr in glShaderSource(vertexShader, 1, ptr, nil) }
        glCompileShader(vertexShader)

        let success = UnsafeMutablePointer<GLMap.Int>.allocate(capacity: 1)
        let info = UnsafeMutablePointer<GLMap.Char>.allocate(capacity: 512)
        glGetShaderiv(vertexShader, GLMap.COMPILE_STATUS, success)
        if (success.pointee == 0) {
            glGetShaderInfoLog(vertexShader, 512, nil, info)
            throw ShaderError(String(cString: info))
        } else {
            print("Vertex shader successfully compiled.")
        }

        let fragmentShader = glCreateShader(GLMap.FRAGMENT_SHADER)
        withUnsafePointer(to: fragmentSource) { ptr in GL.glShaderSource(fragmentShader, 1, ptr, nil) }
        glCompileShader(fragmentShader)
        glGetShaderiv(fragmentShader, GLMap.COMPILE_STATUS, success)
        if (success.pointee == 0) {
            glGetShaderInfoLog(fragmentShader, 512, nil, info)
            throw ShaderError(String(cString: info))
        } else {
            print("Fragment shader successfully compiled.")
        }

        self.id = glCreateProgram()
        glAttachShader(self.id!, vertexShader)
        glAttachShader(self.id!, fragmentShader)
        glLinkProgram(self.id!)

        glGetProgramiv(self.id!, GLMap.LINK_STATUS, success)
        if (success.pointee == 0) {
            glGetProgramInfoLog(self.id!, 512, nil, info)
            throw ShaderError(String(cString: info))
        } else {
            print("Shader program linked successfully.")
        }

        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
    }

    open func use() {
        
        guard let id = self.id else {
            fatalError("Called use on shader before it was compiled.")
        }

        glUseProgram(id)
    }
}