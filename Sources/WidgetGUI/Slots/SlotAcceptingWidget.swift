public protocol SlotAcceptingWidget: Widget {
}

extension SlotAcceptingWidget {
  public func content(
    @ExpSlottingContentBuilder content buildContent: () -> ExpSlottingContent 
  ) -> Self {
    let content = buildContent()
    // TODO: could set the default slot here
    resolveSlotContentWrappers(content)
    // accessing content in this closure should capture the content object
    // the handler is removed when the widget is destroyed -> content object
    // is released
    _ = onDestroy(content.onChanged { [unowned self] in
      resolveSlotContentWrappers(content)
    })
    return self
  }

  fileprivate func resolveSlotContentWrappers(_ content: ExpSlottingContent) {
    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if let slotContent = child.value as? AnySlotContent {
        slotContent.anyContainer = content.getSlotContentDefinition(for: slotContent.anySlot)
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