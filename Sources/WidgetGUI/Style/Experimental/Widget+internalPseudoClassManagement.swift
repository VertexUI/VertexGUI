extension Widget {
  internal func _enablePseudoClass(_ pseudoClass: PseudoClass) {
    pseudoClasses.insert(pseudoClass.asString)
    self.notifySelectorChanged()
  }

  internal func _disablePseudoClass(_ pseudoClass: PseudoClass) {
    pseudoClasses.remove(pseudoClass.asString)
    self.notifySelectorChanged()
  }
}