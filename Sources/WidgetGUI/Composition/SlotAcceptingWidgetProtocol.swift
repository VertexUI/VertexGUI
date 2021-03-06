public protocol SlotAcceptingWidgetProtocol: Widget {
  var defaultNoDataSlotContentManager: SlotContentManager<Void>? { get }
}

extension SlotAcceptingWidgetProtocol {
  public var defaultNoDataSlotContentManager: SlotContentManager<Void>? {
    nil
  }

  func internalWithContent(
    buildContent: (Self.Type) -> ExpSlottingContent 
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

  public func withContent(
    @ExpSlottingContentBuilder _ buildContent: (Self.Type) -> ExpSlottingContent
  ) -> Self {
    internalWithContent(buildContent: buildContent)
  }

  public func withContent(
    @ExpSlottingContentBuilder _ buildContent: () -> ExpSlottingContent
  ) -> Self {
    internalWithContent(buildContent: { _ in buildContent() })
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