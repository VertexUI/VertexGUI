import GfxMath

open class Layout {
  public internal(set) var widgets: [Widget] = []

  required public init(widgets: [Widget]) {}

  open func getBoxConfig() -> BoxConfig {
    fatalError("getBoxConfig() not implemented")
  }

  open func layout(constraints: BoxConstraints) -> DSize2 {
    fatalError("layout() not implemented")
  }
}