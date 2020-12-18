public protocol AnyStyleProperties {
  //var selector: WidgetSelector? { get set }
  //var subStyles: [AnyStyle]? { get set }
  func getProperties() -> [(name: String, wrapper: AnyStyleProperty)]
}

extension AnyStyleProperties {
  public func getProperties() -> [(name: String, wrapper: AnyStyleProperty)] {
    var properties = [(name: String, wrapper: AnyStyleProperty)]()
    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if let property = child.value as? AnyStyleProperty {
        properties.append((name: child.label!, wrapper: property))
      }
    }
    return properties
  }
}

public func == (lhs: AnyStyleProperties, rhs: AnyStyleProperties) -> Bool {
  let properties1 = lhs.getProperties()
  let properties2 = rhs.getProperties()

  for property1 in properties1 {
    // TODO: FINISH COMPARISON FUNCTION
    if !properties2.contains { $0.name == property1.name && $0.wrapper == property1.wrapper } {
      return false
    }
  }

  return true
}

public protocol StyleProperties: AnyStyleProperties {
  init()
  //init(_ selector: WidgetSelector, _ configure: (inout Self) -> ())
  init(_ configure: (inout Self) -> ())

  //func sub(@StyleBuilder _ styles: () -> [AnyStyle])
}

extension StyleProperties {
  /*public init(_ selector: WidgetSelector, _ configure: (inout Self) -> ()) {
    self.init()
    self.selector = selector
    configure(&self)
  }*/

  public init(_ configure: (inout Self) -> ()) {
    self.init()
    configure(&self)
  }



  /*mutating public func sub(@StyleBuilder _ styles: () -> [AnyStyle]) {
    if subStyles == nil {
      subStyles = []
    }
    subStyles!.append(contentsOf: styles())
  }*/
}