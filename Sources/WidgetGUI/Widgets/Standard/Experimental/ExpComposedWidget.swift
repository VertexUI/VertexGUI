extension Experimental {
  open class ComposedWidget: Widget {
    open var rootChild: Widget?

    override open func getBoxConfig() -> BoxConfig {
      rootChild!.getBoxConfig()
    }
  }
}