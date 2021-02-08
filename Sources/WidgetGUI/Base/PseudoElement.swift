open class PseudoElement {
  open var identifier: String {
    fatalError("identifier not implemented")
  }
  //public let stylePropertiesResolver = StylePropertiesResolver()

  public init() {}
}