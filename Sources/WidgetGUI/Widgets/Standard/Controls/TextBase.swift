import GfxMath
import Foundation
import VisualAppBase

open class TextBase: Widget, SimpleStylableWidget {
  public var displayedText: String {
    didSet {
      handleTextChange()
    }
  }
  private var transformedText: String {   
    filledStyleProperties.transform!.apply(to: displayedText)
  }

  public var directStyleProperties: [AnyStyleProperties] = []
  public private(set) lazy var filledStyleProperties: StyleProperties = getFilledStyleProperties()
  public var fontConfig: FontConfig {
    FontConfig(
      family: filledStyleProperties.fontFamily!,
      size: filledStyleProperties.fontSize!,
      weight: filledStyleProperties.fontWeight!,
      style: filledStyleProperties.fontStyle!)
  }
  public static let defaultStyleProperties = StyleProperties {
    $0.fontFamily = defaultFontFamily
    $0.fontSize = 16
    $0.fontWeight = .regular
    $0.fontStyle = .Normal
    $0.transform = .None
    $0.foreground = .black
    $0.wrap = true
  }

  public init(text: String = "") {
    self.displayedText = text
  }

  override public func getBoxConfig() -> BoxConfig {
    var boxConfig = BoxConfig(
      preferredSize: context.getTextBoundsSize(transformedText, fontConfig: fontConfig))

    if !filledStyleProperties.wrap! {
      boxConfig.minSize = boxConfig.preferredSize
    }

    return boxConfig
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    let boundedText = transformedText.isEmpty ? " " : transformedText

    var textBoundsSize = context.getTextBoundsSize(
      boundedText, fontConfig: fontConfig, maxWidth: filledStyleProperties.wrap! ? constraints.maxWidth : nil
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
    let partialText = String(displayedText[..<displayedText.index(displayedText.startIndex, offsetBy: index)])
    let transformedText = filledStyleProperties.transform!.apply(to: partialText)

    if transformedText.isEmpty {
      preferredSize.height = context.getTextBoundsSize(" ", fontConfig: fontConfig).height
    } else {
      if filledStyleProperties.wrap! {
        preferredSize = context.getTextBoundsSize(
          transformedText, fontConfig: fontConfig, maxWidth: previousConstraints!.maxWidth)
      } else {
        preferredSize = context.getTextBoundsSize(transformedText, fontConfig: fontConfig)
      }
    }

    return DRect(min: .zero, max: DVec2(preferredSize))
  }

  private func handleTextChange() {
    invalidateBoxConfig()
    invalidateRenderState()
  }

  override public func renderContent() -> RenderObject? {
    let maxWidth = filledStyleProperties.wrap! ? bounds.size.width : nil

    if let previousContent = renderState.mainContent as? TextRenderObject {
      previousContent.text = transformedText
      previousContent.fontConfig = fontConfig
      previousContent.color = filledStyleProperties.foreground!
      previousContent.topLeft = globalPosition
      previousContent.maxWidth = maxWidth
      return previousContent
    } else {
      return TextRenderObject(
        transformedText, fontConfig: fontConfig, color: filledStyleProperties.foreground!,
        topLeft: globalPosition, maxWidth: maxWidth)
    }
  }

  public func acceptsStyleProperties(_ properties: AnyStyleProperties) -> Bool {
    properties as? StyleProperties != nil || properties as? AnyForegroundStyleProperties != nil
  }
}

extension TextBase {
  public struct StyleProperties: WidgetGUI.StyleProperties, ForegroundStyleProperties {
    @StyleProperty
    public var fontFamily: FontFamily?

    @StyleProperty
    public var fontSize: Double?

    @StyleProperty
    public var fontWeight: FontWeight?

    @StyleProperty
    public var fontStyle: FontStyle?

    @StyleProperty
    public var transform: TextTransform?

    @StyleProperty
    public var foreground: Color? 

    @StyleProperty
    public var wrap: Bool?

    public init() {}
  }
}