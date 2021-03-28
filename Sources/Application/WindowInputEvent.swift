import GfxMath

public protocol WindowInputEvent {
}

public struct WindowMouseMoveEvent: WindowInputEvent {
  public var position: DVec2
  public var positionDelta: DVec2
  
  public init(position: DVec2, positionDelta: DVec2) {
    self.position = position
    self.positionDelta = positionDelta
  }
}

public struct WindowMouseButtonDownEvent: WindowInputEvent {
  public init() {}
}