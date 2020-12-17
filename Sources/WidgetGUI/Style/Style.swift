public protocol AnyStyle {
  var anyProperties: AnyStyleProperties { get set }
  var selector: WidgetSelector? { get set }
}

public struct Style<Properties: StyleProperties>: AnyStyle {
  public var properties: Properties 
  public var anyProperties: AnyStyleProperties {
    get {
      properties
    }
    set {
      properties = newValue as! Properties
    }
  }
  public var selector: WidgetSelector?
  
  public init(_ selector: WidgetSelector? = nil, _ configure: (inout Properties) -> ()) {
    self.selector = selector
    self.properties = Properties()
    configure(&properties)
  }
}