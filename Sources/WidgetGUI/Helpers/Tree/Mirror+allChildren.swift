extension Mirror {
  public var allChildren: [Mirror.Child] {
    var allChildren: [Mirror.Child] = []
    var mirror: Mirror! = self
    repeat {
      allChildren.append(contentsOf: mirror.children)
      mirror = mirror.superclassMirror
    } while mirror != nil
    return allChildren
  }
}
