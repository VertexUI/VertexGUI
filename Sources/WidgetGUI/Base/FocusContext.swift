public class FocusContext {
  public var focusLeaf: Widget?

  public func requestFocus(_ widget: Widget) {
    focusLeaf = widget
  }
  // TODO: implement focus handling like this: https://doc.qt.io/qt-5/qtquick-input-focus.html
}