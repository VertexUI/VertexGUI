public class StyleManager {
  private let rootWidget: Widget 

  public init(rootWidget: Widget) {
    self.rootWidget = rootWidget 
  }

  public func setup() {
    processTree(rootWidget)
  }

  public func refresh(_ widgets: [Widget]) {
    for widget in widgets {
      processTree(widget)
    }
  }

  public func processTree(_ initialWidget: Widget) {
    var parentStyles = [StyleWrapper]()

    var nextParent = Optional(initialWidget)
    while let currentParent = nextParent {
      parentStyles.append(contentsOf: currentParent.providedStyles.map { StyleWrapper(style: $0, source: currentParent) })
      nextParent = currentParent.parent as? Widget 
    }

    applyStyles(parentStyles, to: initialWidget)

    var iterators: [(iterator: Widget.ChildIterator, branchStyles: [StyleWrapper])] = [(iterator: initialWidget.visitChildren(), branchStyles: parentStyles)]

    while var (iterator, branchStyles) = iterators.first {
      while let widget = iterator.next() {
        let widgetProvidedStyles = widget.providedStyles.map { StyleWrapper(style: $0, source: widget) }
        iterators.append((iterator: widget.visitChildren(), branchStyles: branchStyles + widgetProvidedStyles))
        applyStyles(branchStyles + widgetProvidedStyles, to: widget) 
      }
      iterators.removeFirst()
    }
  }

  public func applyStyles(_ styleWrappers: [StyleWrapper], to widget: Widget) {
    widget.appliedStyles = []
    for styleWrapper in styleWrappers {
      if styleWrapper.style.selector == nil || styleWrapper.style.selector!.selects(widget) {
        widget.appliedStyles.append(styleWrapper.style)
      }
    }
  }
}

public struct StyleWrapper {
  public let style: AnyStyle
  public let source: Widget

  public init(style: AnyStyle, source: Widget) {
    self.style = style
    self.source = source
  }
}