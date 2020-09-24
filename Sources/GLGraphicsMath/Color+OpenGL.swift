import GL
import CustomGraphicsMath

public extension Color {

    public var glR: GLMap.Float {
        get {
            return Float(r) / Float(255)
        }
    } 

    public var glG: GLMap.Float {
        get {
            return Float(g) / Float(255)
        }
    }

    public var glB: GLMap.Float {
        get {
            return Float(b) / Float(255)
        }
    }

    public var glA: GLMap.Float {
        get {
            return Float(a) / Float(255)
        }
    }

    public var gl: [Float] {

        [glR, glG, glB, glA]
    }
}