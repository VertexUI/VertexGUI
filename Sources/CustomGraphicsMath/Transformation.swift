// TODO: maybe this class is not needed, might just put it into Matrix
public struct Transformation<E: FloatingPointGenericMath> {
    public var translation: AnyVector3<E> {
        didSet {
            recalc()
        }
    }
    public var scaling: AnyVector3<E> {
        didSet {
            recalc()
        }
    }
    public var rotationAxis: AnyVector3<E> {
        didSet {
            recalc()
        }
    }
    public var rotationAngle: E {
        didSet {
            recalc()
        }
    }
    public var matrix: AnyMatrix4<E>

    public init() {
        self.translation = AnyVector3<E>()
        self.scaling = AnyVector3<E>([1, 1, 1])
        self.rotationAxis = AnyVector3<E>([1, 1, 1])
        self.rotationAngle = E.zero
        self.matrix = AnyMatrix4<E>()
        recalc()
    }

    public init(translation: AnyVector3<E>, scaling: AnyVector3<E>, rotationAxis: AnyVector3<E>, rotationAngle: E) {
        self.translation = translation
        self.scaling = scaling
        self.rotationAxis = rotationAxis
        self.rotationAngle = rotationAngle
        self.matrix = AnyMatrix4<E>()
        recalc()
    }

    public mutating func recalc() {
        matrix = AnyMatrix4<E>.transformation(translation: translation, scaling: scaling, rotationAxis: rotationAxis, rotationAngle: rotationAngle)
    }
}