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

    var nextParent = initialWidget.parent as? Widget
    while let currentParent = nextParent {
      let stylesApplicableToParent = parentStyles + currentParent.providedStyles
      let freedParentStyles = getFreedSubStyles(stylesApplicableToParent, currentParent)
      parentStyles.append(contentsOf: currentParent.providedStyles.filter {
        !$0.extendsParent
      })
      parentStyles.append(contentsOf: freedParentStyles)
      nextParent = currentParent.parent as? Widget 
    }

    initialWidget.appliedStyles = []
    let stylesApplicableToInitialWidget = parentStyles + initialWidget.providedStyles
    applyStyles(stylesApplicableToInitialWidget, to: initialWidget)

    let initialWidgetFreedStyles = getFreedSubStyles(stylesApplicableToInitialWidget, initialWidget)
    let initialBranchStyles = parentStyles + 
      initialWidget.providedStyles.filter { !$0.extendsParent } +
      initialWidgetFreedStyles

    var iterators: [(iterator: Widget.ChildIterator, branchStyles: [AnyStyle])] = [(iterator: initialWidget.visitChildren(), branchStyles: initialBranchStyles)]

    while var (iterator, branchStyles) = iterators.first {
      while let widget = iterator.next() {
        widget.appliedStyles = []
        
        let stylesApplicableToWidget = branchStyles + widget.providedStyles

        if let widget = widget as? StylableWidget {
          applyStyles(stylesApplicableToWidget, to: widget)
        }

        let freedSubStyles = getFreedSubStyles(stylesApplicableToWidget, widget)
        let stylesApplicableToWidgetThatCanBePassedDown = widget.providedStyles.filter {
          !$0.extendsParent
        }
        let allStylesThatCanBePassedDown = branchStyles + stylesApplicableToWidgetThatCanBePassedDown + freedSubStyles
        iterators.append((iterator: widget.visitChildren(), branchStyles: allStylesThatCanBePassedDown))
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