import GfxMath
import Foundation
import VisualAppBase

open class TextBase: Widget {
  public var _text: String {
    didSet {
      handleTextChange()
    }
  }
  private var transformedText: String {
    textStyle.transform.apply(to: _text)
  }

  public var textStyle: TextStyle
  public static let defaultTextStyle = TextStyle(
    fontConfig: FontConfig(
      family: defaultFontFamily,
      size: 16,
      weight: .Regular,
      style: .Normal
    ),
    transform: .None,
    color: .Black,
    wrap: true)

  public init(text: String = "", style: TextStyle = TextBase.defaultTextStyle) {
    self._text = text
    self.textStyle = style
  }

  override public func getBoxConfig() -> BoxConfig {
    var boxConfig = BoxConfig(
      preferredSize: context.getTextBoundsSize(transformedText, fontConfig: textStyle.fontConfig))

    if !textStyle.wrap {
      boxConfig.minSize = boxConfig.preferredSize
    }

    return boxConfig
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    let boundedText = transformedText.isEmpty ? " " : transformedText

    var textBoundsSize = context.getTextBoundsSize(
      boundedText, fontConfig: textStyle.fontConfig, maxWidth: textStyle.wrap ? constraints.maxWidth : nil
    )
    
    if transformedText.isEmpty {
      textBoundsSize.width = 0
    }

    // fix glitches that create unnecessary line breaks, probably because floating point inprecisions
    // might need to be larger
    textBoundsSize.width += 4

    return constraints.constrain(textBoundsSize)
  }

  /// This function is used in TextInput to get the coordinates where the caret should be displayed.
  /// - Returns: The local bounding rect (origin: self -> topLeft) up to (including) the specified index inside the text.
  /// - Parameter to: Up to which character index (including the index) to return the bounds.
  /// - Misc:
  /// TODO: maybe put this somewhere else
  public func getSubBounds(to index: Int) -> DRect {
    var preferredSize = DSize2.zero
    let partialText = String(_text[..<_text.index(_text.startIndex, offsetBy: index)])
    let transformedText = textStyle.transform.apply(to: partialText)

    if transformedText.isEmpty {
      preferredSize.height = context.getTextBoundsSize(" ", fontConfig: textStyle.fontConfig).height
    } else {
      if textStyle.wrap {
        preferredSize = context.getTextBoundsSize(
          transformedText, fontConfig: textStyle.fontConfig, maxWidth: previousConstraints!.maxWidth)
      } else {
        preferredSize = context.getTextBoundsSize(transformedText, fontConfig: textStyle.fontConfig)
      }
    }

    return DRect(min: .zero, max: DVec2(preferredSize))
  }

  private func handleTextChange() {
    invalidateBoxConfig()
    invalidateRenderState()
  }

  override public func renderContent() -> RenderObject? {
    let maxWidth = textStyle.wrap ? bounds.size.width : nil

    if let previousContent = renderState.mainContent as? TextRenderObject {
      previousContent.text = transformedText
      previousContent.fontConfig = textStyle.fontConfig
      previousContent.color = textStyle.color
      previousContent.topLeft = globalPosition
      previousContent.maxWidth = maxWidth
      return previousContent
    } else {
      return TextRenderObject(
        transformedText, fontConfig: textStyle.fontConfig, color: textStyle.color,
        topLeft: globalPosition, maxWidth: maxWidth)
    }
  }
}

extension TextBase {
  public struct TextStyle {
    public var fontConfig: FontConfig
    public var transform: TextTransform
    public var color: Color
    public var wrap: Bool
  }
}