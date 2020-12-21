public protocol AnyStyle {
  var anyProperties: AnyStyleProperties { get set }
  var selector: StyleSelector? { get set }
  var subStyles: [AnyStyle] { get set }
  var extendsParent: Bool { get }

  /**
  - Returns: `true` (if the selector is nil and widget implements StylableWidget and `widget.acceptsStyleProperties` returns `true`) or (if `selector.selects` returns true)
  */
  func applies(to widget: Widget) -> Bool
}

extension AnyStyle {
  public var extendsParent: Bool {
    selector == nil ? false : selector!.extendsParent
  }

  public func applies(to widget: Widget) -> Bool {
    if selector == nil, let widget = widget as? StylableWidget, widget.acceptsStyleProperties(anyProperties) {
      return true
    } else if let selector = selector {
      return selector.selects(widget)
    } else {
      return false
    }
  }
}

public func == (lhs: AnyStyle, rhs: AnyStyle) -> Bool {
  lhs.selector == rhs.selector && lhs.anyProperties == rhs.anyProperties
}

public func != (lhs: AnyStyle, rhs: AnyStyle) -> Bool {
  !(lhs == rhs)
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
  public var selector: StyleSelector?
  public var subStyles: [AnyStyle] = []
  
  public init(_ selector: StyleSelector? = nil, _ configure: (inout Properties) -> ()) {
    self.selector = selector
    self.properties = Properties()
    configure(&properties)
  }

  public init(_ selector: StyleSelector? = nil, _ configure: (inout Properties) -> (), @StyleBuilder sub buildSubStyles: () -> [AnyStyle]) {
    self.init(selector, configure)
    self.subStyles = buildSubStyles()
  }
}