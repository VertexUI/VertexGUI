public protocol PropertyBindingProtocol: class {
  var destroyed: Bool { get }

  func destroy()
}