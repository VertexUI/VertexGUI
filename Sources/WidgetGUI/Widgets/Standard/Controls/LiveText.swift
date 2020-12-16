public class LiveText: TextBase {
  private let getText: () -> String

  public init(getText: @escaping () -> String) {
    self.getText = getText
    super.init(text: getText())
    _ = onTick { _ in
      self.displayedText = self.getText()
    }
  }

/*
  override public func getBoxConfig() -> BoxConfig {
    var boxConfig = BoxConfig(
      preferredSize: context.getTextBoundsSize(transformedText, fontConfig: config.fontConfig))

    if !config.wrap {
      boxConfig.minSize = boxConfig.preferredSize
    }

    return boxConfig
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    let boundedText = transformedText.isEmpty ? " " : transformedText

    var textBoundsSize = context.getTextBoundsSize(
      boundedText, fontConfig: config.fontConfig, maxWidth: config.wrap ? constraints.maxWidth : nil
    )
    
    if transformedText.isEmpty {
      textBoundsSize.width = 0
    }

    // fix glitches that create unnecessary line breaks, probably because floating point inprecisionsj
    // might need to be larger
    textBoundsSize.width += 4

    return constraints.constrain(textBoundsSize)
  }*/
}