public protocol SlotAcceptingWidget: Widget {
}

extension SlotAcceptingWidget {
  public func with(
    classes: [String],
    @StylePropertiesBuilder styleProperties: (Widget.StyleKeys.Type) -> Void,
    @SlotWidgetContentBuilder content buildContent: () -> SlotWidgetContentBuilder.Result
  ) {
    let builderResult = buildContent()
    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if let slotContent = child.value as? AnySlotContent {
        slotContent.container = builderResult.getContent(for: slotContent.anySlot)
      }
    }
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