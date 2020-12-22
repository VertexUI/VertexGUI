public class StyleManager {
  private let rootWidget: Widget 

  public init(rootWidget: Widget) {
    self.rootWidget = rootWidget 
  }

  public func setup() {
    distributeStylesInTree(rootWidget)
  }

  public func refresh(_ widgets: [Widget]) {
    for widget in widgets {
      distributeStylesInTree(widget)
    }
  }

  public func distributeStylesInTree(_ initialWidget: Widget) {
    var parentStyles = [AnyStyle]()

    var nextParent = Optional(initialWidget)
    while let currentParent = nextParent {
      parentStyles.append(contentsOf: currentParent.providedStyles)
      parentStyles.append(contentsOf: getFreedSubStyles(parentStyles, currentParent))
      nextParent = currentParent.parent as? Widget 
    }

    initialWidget.appliedStyles = []
    applyStyles(parentStyles, to: initialWidget)

    var iterators: [(iterator: Widget.ChildIterator, branchStyles: [AnyStyle])] = [(iterator: initialWidget.visitChildren(), branchStyles: parentStyles)]

    while var (iterator, branchStyles) = iterators.first {
      while let widget = iterator.next() {
        widget.appliedStyles = []
        
        let widgetProvidedStyles = widget.providedStyles
        let allAvailableStyles = branchStyles + widgetProvidedStyles

        if let widget = widget as? StylableWidget {
          applyStyles(allAvailableStyles, to: widget)
        } 

        let freedSubStyles = getFreedSubStyles(allAvailableStyles, widget)
        iterators.append((iterator: widget.visitChildren(), branchStyles: allAvailableStyles + freedSubStyles))
      }
      iterators.removeFirst()
    }
  }

  /**
  - Returns: the sub styles of the styles that apply to the given Widget.
  */
  public func getFreedSubStyles(_ styles: [AnyStyle], _ widget: Widget) -> [AnyStyle] {
    var freedStyles = [AnyStyle]()
    var parentExtendingStyles = [AnyStyle]()

    for style in styles {
      if style.applies(to: widget) {
        for subStyle in style.subStyles {
          // when a sub style extends the parent style that matched the Widget
          // add it to the queue of styles which will be checked by a recursive call
          // of this function to also unroll their sub styles if they match
          if subStyle.extendsParent {
            parentExtendingStyles.append(subStyle)
          } else {
            freedStyles.append(subStyle)
          }
        } 
      }
    }

    // TODO: instead of recursive solution might also use a non-recursive one, could increase performance
    if parentExtendingStyles.count > 0 {
      freedStyles.append(contentsOf: getFreedSubStyles(parentExtendingStyles, widget))
    }

    return freedStyles
  }

  /**
  - Returns: the non-parent-extending sub styles of the styles that were applied to the widget
  */
  public func applyStyles(_ styles: [AnyStyle], to widget: Widget) {
    for style in styles {
      if style.applies(to: widget) {
        widget.appliedStyles.append(style)
        // TODO: might find a non recursive approach
        applyStyles(style.subStyles.filter { $0.extendsParent }, to: widget)
      }
    }
  }
}

/*public struct StyleWrapper {
  public let style: AnyStyle
  public let source: Widget

  public init(style: AnyStyle, source: Widget) {
    self.style = style
    self.source = source
  }
}*/