public protocol SlotAcceptingWidget: Widget {
}

extension SlotAcceptingWidget {
  public func content(
    @SlotWidgetContentBuilder content buildContent: () -> SlotWidgetContentBuilder.Result
  ) -> Self {
    let builderResult = buildContent()
    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if let slotContent = child.value as? AnySlotContent {
        slotContent.anyContainer = builderResult.getContent(for: slotContent.anySlot)
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