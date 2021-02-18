public protocol ChildAcceptorWidget: Widget {
}

extension ChildAcceptorWidget {
  public func with(
    classes: [String]? = nil,
    @StylePropertiesBuilder styleProperties: (StyleKeys.Type) -> Void,
    @Widget.ExperimentalMultiChildContentBuilder content buildContent: () -> Widget.ExperimentalMultiChildContentBuilder.Content
  ) {
    let content = buildContent()
    self.provideStyles(content.styles)
    if let classes = classes {
      self.classes.append(contentsOf: classes)
    }
  }
}

extension ChildAcceptorWidget where Self: StylableWidget {
  public func with(
    classes: [String],
    @StylePropertiesBuilder styleProperties: (Self.StyleKeys.Type) -> Void,
    @Widget.ExperimentalMultiChildContentBuilder content buildContent: () -> Widget.ExperimentalMultiChildContentBuilder.Content
  ) {

  }
}