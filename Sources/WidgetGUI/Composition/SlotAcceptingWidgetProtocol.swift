public protocol SlotAcceptingWidgetProtocol: Widget {
  var defaultNoDataSlotContentManager: SlotContentManager<Void>? { get }
}

extension SlotAcceptingWidgetProtocol {
  public var defaultNoDataSlotContentManager: SlotContentManager<Void>? {
    nil
  }

  func internalWithContent(
    buildContent: (Self.Type) -> SlottingContent 
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
    _ = onDestroy(content.onChanged { [weak self] in
      self?.resolveSlotContentWrappers(content)
      
      if let defaultManager = self?.defaultNoDataSlotContentManager, defaultManager.anyDefinition == nil {
        defaultManager.anyDefinition = defaultDefinition
      }
    })
    return self
  }

  public func withContent(
    @SlottingContentBuilder _ buildContent: (Self.Type) -> SlottingContent
  ) -> Self {
    internalWithContent(buildContent: buildContent)
  }

  public func withContent(
    @SlottingContentBuilder _ buildContent: () -> SlottingContent
  ) -> Self {
    internalWithContent(buildContent: { _ in buildContent() })
  }

  fileprivate func resolveSlotContentWrappers(_ content: SlottingContent) {
    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if let slotContentManager = child.value as? AnySlotContentManager {
        slotContentManager.anyDefinition = content.getSlotContentDefinition(
          for: slotContentManager.anySlot)
      }
    }
  }
}
