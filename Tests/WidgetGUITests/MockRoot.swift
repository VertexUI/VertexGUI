import WidgetGUI
import GfxMath

class MockRoot: Root {
  override public init(rootWidget: Widget) {
    super.init(rootWidget: rootWidget)
    self.setup(
      window: try! Window(options: Window.Options()),
      getTextBoundsSize: { _, _, _ in DSize2.zero },
      measureText: { _, _ in .zero },
      getKeyStates: { KeyStatesContainer() },
      getApplicationTime: { 0 },
      getRealFps: { 0 },
      createWindow: { _, _ in try! Window(options: Window.Options()) },
      requestCursor: { _ in {} } )
  }

  public func tick() {
    tick(Tick(deltaTime: 0, totalTime: 0))
  }
}