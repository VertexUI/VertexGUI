public protocol Style {
  var selector: WidgetSelector { get set }

  //init()
  //init(_ selector: WidgetSelector)
}

extension Style {
  /*public init(_ selector: WidgetSelector) {
    self.init()
    self.selector = selector
  }*/
}