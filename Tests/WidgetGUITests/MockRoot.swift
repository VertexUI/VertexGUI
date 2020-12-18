import WidgetGUI
import VisualAppBase
import GfxMath

class MockRoot: Root {
  override public init(rootWidget: Widget) {
    super.init(rootWidget: rootWidget)
    self.setup(widgetContext: WidgetContext(
      window: try! Window(options: Window.Options()),
      getTextBoundsSize: { _, _, _ in DSize2.zero },
      getApplicationTime: { 0 },
      getRealFps: { 0 },
      createWindow: { _, _ in try! Window(options: Window.Options()) },
      requestCursor: { _ in {} } ))
  }
}