import CustomGraphicsMath

public enum GameEvent {
    case Add(id: UInt, position: DPoint2, radius: Double, creationTimestamp: Double)
    case Move(id: UInt, position: DPoint2)
    case Grow(id: UInt, radius: Double)
}