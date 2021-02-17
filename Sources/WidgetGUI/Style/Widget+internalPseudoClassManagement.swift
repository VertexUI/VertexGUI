extension Widget {
  public func enablePseudoClass(_ pseudoClass: PseudoClass) {
    pseudoClasses.insert(pseudoClass.asString)
    self.notifySelectorChanged()
  }

  public func disablePseudoClass(_ pseudoClass: PseudoClass) {
    pseudoClasses.remove(pseudoClass.asString)
    self.notifySelectorChanged()
  }
}