import GfxMath

// TODO: maybe this belongs to GraphicsMath
public struct Path: Hashable {

    public var segments: [Segment]

    public init(_ segments: [Segment]) {
        self.segments = segments
    }

    public init(_ segments: Segment...) {
        self.segments = segments
    }

    public enum Segment: Hashable {
        public enum ArcDirection {
            case Clockwise, Counterclockwise
        }

        // TODO: add bezier

        case Start(_ position: DPoint2)
        case Line(_ position: DPoint2)
        case Arc(center: DPoint2, radius: Double, startAngle: Double, endAngle: Double, direction: ArcDirection)
    }
}