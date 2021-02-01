import GfxMath

open class DrawingContext {
  public let surface: DrawingSurface

  public private(set) var inherentTransforms: [Transform] = []
  public private(set) var inherentOpacity: Double = 1
  private var transforms: [Transform] = []
  private var opacity: Double = 1 {
    willSet {
      checkFailOpacity(newValue)
    }
  }

  public init(surface: DrawingSurface) {
    self.surface = surface
  }

  open func clone() -> DrawingContext {
    fatalError("clone() not implemented")
  }

  /**
  Locks current transforms, opacity by merging them into inherentTransforms, inherentOpacity.
  - Returns: A new DrawingContext instance with the values of these properties locked.
  Which means that they will always be applied and cannot be removed, other transforms etc. can however be added on top of them.
  */
  open func locked(opacity: Double = 1, transforms: [Transform] = []) -> DrawingContext {
    let result = clone()
    result.transform(transforms)
    result.opacity *= opacity
    result.lock()
    return result
  }

  open func lock() {
    self.inherentTransforms.append(contentsOf: transforms)
    self.transforms = []
    self.inherentOpacity *= opacity
    self.opacity = 1
  }

  private func checkFailOpacity(_ opacity: Double) {
    if opacity < 0 || opacity > 1 {
      fatalError("opacity must be between (including) 0 and 1")
    }
  }

  open func beginDrawing() {

  }

  private func applyTransforms(to point: DVec2) -> DVec2 {
    var currentPoint = point
    for transform in inherentTransforms + transforms {
      switch transform {
      case let .translate(translation):
        currentPoint = currentPoint + translation
      }
    }
    return currentPoint
  }

  private func applyTransforms(to rect: DRect) -> DRect {
    let min = applyTransforms(to: rect.min)
    let max = applyTransforms(to: rect.max)
    return DRect(min: min, max: max)
  }

  public func transform(_ transform: Transform) {
    self.transforms.append(transform)
  }

  public func transform(_ transforms: [Transform]) {
    self.transforms.append(contentsOf: transforms)
  }

  public func drawRect(rect: DRect, paint: Paint) {
    _drawRect(rect: applyTransforms(to: rect), paint: paint)
  }

  /** For internal use. Called by drawRect() with all transforms etc. applied. */
  open func _drawRect(rect: DRect, paint: Paint) {
    fatalError("drawRect() not implemented")
  }

  open func drawRoundedRect() {

  }

  open func drawPath() {
    
  }

  open func endDrawing() {

  }

  public enum Transform {
    case translate(DVec2)
  }
}