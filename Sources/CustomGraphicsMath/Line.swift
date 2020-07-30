public protocol Line: CustomDebugStringConvertible {
    associatedtype Vector: CustomGraphicsMath.Vector where Vector.Element: BinaryFloatingPoint

    var point: Vector { get set }
    var direction: Vector { get set }
    
    init()
    init(point: Vector, direction: Vector)
}

public extension Line {
    init(point: Vector, direction: Vector) {
        self.init()
        self.point = point
        self.direction = direction.normalized()
    }

    init(from point1: Vector, to point2: Vector) {
        self.init()
        self.point = point1
        self.direction = (point1 - point2).normalized()
    }

    var debugDescription: String {
        "Line x = (\(point)) + scale * (\(direction))"
    }

    /// assuming: resultVec = pointOnLineVec + scale * directionVec 
    func pointAtScale(_ scale: Vector.Element) -> Vector {
        return point + direction * scale
    }

    func scaleAt(_ point: Vector, accuracy: Vector.Element = Vector.Element(vectorComparisonAccuracy)) -> Vector.Element? {
        var lastScale: Vector.Element?
        for axis in 0..<direction.count {
            if direction[axis] == 0 {
                // TODO: maybe need accuracy here too
                if abs(self.point[axis] - point[axis]) > accuracy {
                    return nil
                }
            } else {
                let scale = (point[axis] - self.point[axis]) / direction[axis]
                if lastScale == nil {
                    lastScale = scale
                } else if abs(scale - lastScale!) > accuracy {
                    return nil
                }
            }
        }
        return lastScale 
    }

    func contains(_ point: Vector, accuracy: Vector.Element = Vector.Element(vectorComparisonAccuracy)) -> Bool {
        return scaleAt(point, accuracy: accuracy) != nil ? true : false
    }

    func pointBetween(test testPoint: Vector, from markPoint1: Vector, to markPoint2: Vector, accuracy: Vector.Element = Vector.Element(vectorComparisonAccuracy)) -> Bool {
        guard let testPointScale = scaleAt(testPoint),
        let markPoint1Scale = scaleAt(markPoint1),
        let markPoint2Scale = scaleAt(markPoint2) else {
            return false
        }

        return
            (testPointScale <= markPoint1Scale + accuracy && testPointScale >= markPoint2Scale - accuracy) ||
            (testPointScale >= markPoint1Scale - accuracy && testPointScale <= markPoint2Scale + accuracy)
    }
}

public extension Line where Vector: Vector2 {
    // TODO: what to return on identical
    /// - Returns: nil if parallel, self.point when identical, intersection point if intersecting
    func intersect<O: Line>(line otherLine: O) -> Vector? where O.Vector == Vector {
        // self --> line1
        // otherLine --> line2
        let slope1 = self.direction.x / self.direction.y
        let slope2 = otherLine.direction.x / otherLine.direction.y
        
        // TODO: which value to use as accuracy?
        if slope1 == slope2 || abs(slope1 - slope2) < Vector.Element(0.1) {
            if contains(otherLine.point) {
                return point
            } else {
                return nil
            }
        }
        
        let scale1 = (otherLine.point - self.point).cross(otherLine.direction) / self.direction.cross(otherLine.direction)

        return pointAtScale(scale1)
    }
}

public extension Line where Vector: Vector3 {
    func intersect<P: Plane>(plane: P) -> Vector? where P.Vector == Vector {
        if plane.normal.dot(direction) == 0 {
            return nil
        }

        let s = (plane.elevation - plane.normal.dot(point)) / (plane.normal.dot(direction))
        return pointAtScale(s)
    }
}

public struct AnyLine<V: Vector>: Line where V.Element: BinaryFloatingPoint {
    public typealias Vector = V
    public var point: V
    public var direction: V
    
    public init() {
        self.point = V()
        self.direction = V()
    }
}