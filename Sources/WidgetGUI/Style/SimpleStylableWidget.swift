public protocol SimpleStylableWidget: Widget, StylableWidget {
  associatedtype StyleProperties: WidgetGUI.StyleProperties
  
  static var defaultStyleProperties: StyleProperties { get }
  var filledStyleProperties: StyleProperties { get }

  /**
  - Returns: `true` if the Widget can handle and apply the given type of StyleProperties. `false` if not.
  */
  func acceptsStyleProperties(_ properties: AnyStyleProperties) -> Bool
  func filterStyleProperties(_ properties: [AnyStyleProperties]) -> [AnyStyleProperties]
  func mergeStyleProperties(_ properties: [AnyStyleProperties]) -> StyleProperties
  func getFilledStyleProperties() -> StyleProperties
}

extension SimpleStylableWidget {
  public typealias Style = WidgetGUI.Style<StyleProperties>

  public func filterStyleProperties(_ properties: [AnyStyleProperties]) -> [AnyStyleProperties] {
    properties.filter {
      acceptsStyleProperties($0)
    }
  }

  public func mergeStyleProperties(_ properties: [AnyStyleProperties]) -> StyleProperties {
    let filteredPartialProperties = filterStyleProperties(properties)

    var result = StyleProperties()

    let resultMirror = Mirror(reflecting: result)

    for partialProperties in filteredPartialProperties {
      let partialMirror = Mirror(reflecting: partialProperties)
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

  public func getFilledStyleProperties() -> StyleProperties {
    mergeStyleProperties([Self.defaultStyleProperties, mergeStyleProperties(styles.map { $0.anyProperties })])
  }
}