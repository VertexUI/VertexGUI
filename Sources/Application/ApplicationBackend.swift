import GfxMath

public protocol ApplicationBackend {
  func setup()

  func processEvents(timeout: Double) throws

  func exit()
}