import GfxMath

open class DrawingContext {
  public let backend: DrawingBackend 

  public private(set) var inherentTransforms: [Transform] = []
  public private(set) var inherentOpacity: Double = 1
  private var transforms: [Transform] = []
  private var opacity: Double = 1 {
    willSet {
      checkFailOpacity(newValue)
    }
  }

  public init(backend: DrawingBackend) {
    self.backend = backend 
  }

  open func clone() -> DrawingContext {
    DrawingContext(backend: backend)
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
    backend.activate()
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

  public func drawLine(from start: DVec2, to end: DVec2, paint: Paint) {
    backend.drawLine(from: applyTransforms(to: start), to: applyTransforms(to: end), paint: paint)
  }

  public func drawRect(rect: DRect, paint: Paint) {
    backend.drawRect(rect: applyTransforms(to: rect), paint: paint)
  }

  open func drawRoundedRect() {

  }

  open func drawPath() {
    
  }

  /**
  // TODO: maybe the result should be a rect to also have access to the position
  */
  public func measureText(text: String, paint: TextPaint) -> DSize2 {
    backend.measureText(text: text, paint: paint)
  }

  public func drawText(text: String, position: DVec2, paint: TextPaint) {
    backend.drawText(text: text, position: applyTransforms(to: position), paint: paint)
  }

  open func endDrawing() {
    backend.deactivate()
  }

  public enum Transform {
    case translate(DVec2)
  }
}