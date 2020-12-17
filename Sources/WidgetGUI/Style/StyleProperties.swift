public protocol AnyStyleProperties {
  //var selector: WidgetSelector? { get set }
  //var subStyles: [AnyStyle]? { get set }
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