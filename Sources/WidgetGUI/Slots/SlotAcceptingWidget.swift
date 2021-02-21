public protocol SlotAcceptingWidget: Widget {
  var defaultNoDataSlotContentManager: SlotContentManager<Void>? { get }
}

extension SlotAcceptingWidget {
  public var defaultNoDataSlotContentManager: SlotContentManager<Void>? {
    nil
  }

  public func with(@StylePropertiesBuilder styleProperties: (StyleKeys.Type) -> StyleProperties) -> Self {
    self.directStyleProperties.append(styleProperties(Self.StyleKeys.self))
    return self
  }

  public func content(
    @ExpSlottingContentBuilder content buildContent: (Self.Type) -> ExpSlottingContent 
  ) -> Self {
    let content = buildContent(Self.self)

    resolveSlotContentWrappers(content)

    var defaultDefinition: SlotContentDefinition<Void>? = nil
    if let defaultManager = defaultNoDataSlotContentManager {
      defaultDefinition = SlotContentDefinition(slot: defaultManager.slot as! Slot<Void>) { [unowned content] in
        content.directContent
      }

      if defaultManager.anyDefinition == nil {
        // apply default definition afterward to ensure that it is not overwritten with nil by the resolve logic
        defaultManager.anyDefinition = defaultDefinition
      }
    }

    // accessing content in this closure should capture the content object
    // the handler is removed when the widget is destroyed -> content object
    // is released
    _ = onDestroy(content.onChanged { [unowned self] in
      resolveSlotContentWrappers(content)
      
      if let defaultManager = defaultNoDataSlotContentManager, defaultManager.anyDefinition == nil {
        defaultManager.anyDefinition = defaultDefinition
      }
    })
    return self
  }

  fileprivate func resolveSlotContentWrappers(_ content: ExpSlottingContent) {
    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if let slotContentManager = child.value as? AnySlotContentManager {
        slotContentManager.anyDefinition = content.getSlotContentDefinition(
          for: slotContentManager.anySlot)
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