public protocol AnyStyle {
  var selector: WidgetSelector? { get set }
}

public protocol Style: AnyStyle {
  init()
  //init(_ selector: WidgetSelector)
  init(_ selector: WidgetSelector, _ configure: (inout Self) -> ())
  init(_ configure: (inout Self) -> ())

  func sub(@StyleBuilder _ styles: () -> [AnyStyle])
}

extension Style {
  public init(_ selector: WidgetSelector, _ configure: (inout Self) -> ()) {
    self.init()
    self.selector = selector
    configure(&self)
  }

  public init(_ configure: (inout Self) -> ()) {
    self.init()
    configure(&self)
  }

  public func sub(@StyleBuilder _ styles: () -> [AnyStyle]) {

  }
  /*public init(_ selector: WidgetSelector) {
    self.init()
    self.selector = selector
  }*/
}

@_functionBuilder
public struct StyleBuilder {
  public static func buildBlock(_ styles: [AnyStyle]) -> [AnyStyle] {
    styles
  }
}