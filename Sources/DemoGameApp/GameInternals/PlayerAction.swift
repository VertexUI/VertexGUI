import GfxMath

public enum PlayerAction {
    case Motion(accelerationDirection: DVec2, speedLimit: Double)
}