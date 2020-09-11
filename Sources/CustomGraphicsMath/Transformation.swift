// TODO: maybe this class is not needed, might just put it into MatrixProtocol
public struct Transformation<E: FloatingPointGenericMath> {
    public var translation: Vector3<E> {
        didSet {
            recalc()
        }
    }
    public var scaling: Vector3<E> {
        didSet {
            recalc()
        }
    }
    public var rotationAxis: Vector3<E> {
        didSet {
            recalc()
        }
    }
    public var rotationAngle: E {
        didSet {
            recalc()
        }
    }
    public var matrix: Matrix4<E>

    public init() {
        self.translation = Vector3<E>()
        self.scaling = Vector3<E>([1, 1, 1])
        self.rotationAxis = Vector3<E>([1, 1, 1])
        self.rotationAngle = E.zero
        self.matrix = Matrix4<E>()
        recalc()
    }

    public init(translation: Vector3<E>, scaling: Vector3<E>, rotationAxis: Vector3<E>, rotationAngle: E) {
        self.translation = translation
        self.scaling = scaling
        self.rotationAxis = rotationAxis
        self.rotationAngle = rotationAngle
        self.matrix = Matrix4<E>()
        recalc()
    }

    public mutating func recalc() {
        matrix = Matrix4<E>.transformation(translation: translation, scaling: scaling, rotationAxis: rotationAxis, rotationAngle: rotationAngle)
    }
}