public protocol SlotAcceptingWidget: Widget {
}

extension SlotAcceptingWidget {
  public func content(
    @ExpSlottingContentBuilder content buildContent: () -> ExpSlottingContent 
  ) -> Self {
    let content = buildContent()
    // TODO: could set the default slot here
    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if let slotContent = child.value as? AnySlotContent {
        slotContent.anyContainer = content.getSlotContentDefinition(for: slotContent.anySlot)
      }
    }
    return self
  }
}

extension ChildAcceptorWidget where Self: StylableWidget {
  /*public func with(
    classes: [String],
    @StylePropertiesBuilder styleProperties: (Self.StyleKeys.Type) -> Void,
    @Widget.ExperimentalMultiChildContentBuilder content buildContent: () -> Widget.ExperimentalMultiChildContentBuilder.Content
  ) {

  }*/
}