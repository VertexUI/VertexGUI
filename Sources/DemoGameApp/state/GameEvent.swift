import CustomGraphicsMath

public enum GameEvent {
    case Add(id: UInt, type: BlobType, position: DPoint2, radius: Double)
    case Accelerate(id: UInt, acceleration: DVec2)
    case Move(id: UInt, position: DPoint2)
    case Grow(id: UInt, radius: Double)
    case Remove(id: UInt)
}