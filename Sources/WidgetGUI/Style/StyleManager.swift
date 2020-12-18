public class StyleManager {
  private let rootWidget: Widget 
  
  private var styles: [StyleWrapper] = []

  public init(rootWidget: Widget) {
    self.rootWidget = rootWidget 
  }

  public func setup() {
    retrieveStyles(rootWidget)
  }

  public func refresh(_ widgets: [Widget]) {
    for widget in widgets {
      retrieveStyles(widget)
    }
  }

  public func retrieveStyles(_ initialWidget: Widget) {
    var iterators = [initialWidget.visitChildren()]

    while var iterator = iterators.last {
      if let widget = iterator.next() {
        styles.append(contentsOf: widget.providedStyles.map { StyleWrapper(style: $0, source: widget) })
        iterators[iterators.count - 1] = iterator // to store the advancement by next()
        iterators.append(widget.visitChildren())
        continue
      } else {
        iterators.removeLast()
      }
    }

    print("RETRIEVED STYLES", styles)
  }

  public func applyStyles() {

  }
}

public struct StyleWrapper {
  private let style: AnyStyle
  private let source: Widget

  public init(style: AnyStyle, source: Widget) {
    self.style = style
    self.source = source
  }
}