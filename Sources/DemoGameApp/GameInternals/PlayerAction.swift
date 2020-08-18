import CustomGraphicsMath

public enum PlayerAction {
    case Motion(accelerationDirection: DVec2, speedLimit: Double)
}