public protocol SimpleStylableWidget: Widget, StylableWidget {
  associatedtype Style: WidgetGUI.Style
  
  static var defaultStyle: Style { get }
  var filledStyle: Style { get }

  func acceptsStyle(_ style: AnyStyle) -> Bool
  func filterStyles(_ styles: [AnyStyle]) -> [AnyStyle]
  func mergeStyles(_ styles: [AnyStyle]) -> Style
  func getFilledStyle() -> Style
}

extension SimpleStylableWidget {
  public func filterStyles(_ styles: [AnyStyle]) -> [AnyStyle] {
    styles.filter {
      acceptsStyle($0)
    }
  }

  public func mergeStyles(_ styles: [AnyStyle]) -> Style {
    let filteredPartialStyles = filterStyles(styles)

    var result = Style()

    let resultMirror = Mirror(reflecting: result)

    for partialStyle in filteredPartialStyles {
      let partialMirror = Mirror(reflecting: partialStyle)
      for partialChild in partialMirror.children {
        if let partialProperty = partialChild.value as? AnyStyleProperty, partialProperty.anyValue != nil {
          for resultChild in resultMirror.children {
            if resultChild.label == partialChild.label, let resultProperty = resultChild.value as? AnyStyleProperty {
              resultProperty.anyValue = partialProperty.anyValue
            }
          }
        }
      }
    }

    return result
  }

  public func getFilledStyle() -> Style {
    mergeStyles([Self.defaultStyle, mergeStyles(styles)])
  }
}