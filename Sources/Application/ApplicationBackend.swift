import GfxMath

public protocol ApplicationBackend {
  func setup()

  func createWindow(initialSize: DSize2) -> Window

  func processEvents(timeout: Double) throws

  func exit()
}