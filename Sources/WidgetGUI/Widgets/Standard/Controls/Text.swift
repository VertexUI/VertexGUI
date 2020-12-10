//

//

import GfxMath
import Foundation
import VisualAppBase

public final class Text: Widget, ConfigurableWidget {
  @ObservableProperty
  public var text: String

  private var transformedText: String {
    config.transform.apply(to: text)
  }

  public static var defaultConfig = Config(
    fontConfig: FontConfig(
      family: defaultFontFamily,
      size: 16,
      weight: .Regular,
      style: .Normal
    ), transform: .None, color: .Black, wrap: true)
  public var localPartialConfig: PartialConfig?
  public var localConfig: Config?
  lazy public var config: Config = combineConfigs()

  public init(_ text: ObservablePropertyBinding<String>) {
    self._text = text
    super.init()
    _ = onDestroy(
      self._text.onChanged { [unowned self] _ in
        // TODO: maybe check whether text size changed and then invalidate??
        invalidateBoxConfig()
        invalidateLayout()
        invalidateRenderState()
      })
  }

  public convenience init(
    _ text: String,
    fontFamily: FontFamily? = nil,
    fontSize: Double? = nil,
    fontWeight: FontWeight? = nil,
    fontStyle: FontStyle? = nil,
    transform: TextTransform? = nil,
    color: Color? = nil,
    wrap: Bool? = nil
  ) {
    self.init(StaticProperty(text).binding)
    with(
      config: PartialConfig(
        fontConfig: PartialFontConfig(
          family: fontFamily,
          size: fontSize,
          weight: fontWeight,
          style: fontStyle
        ),
        transform: transform,
        color: color,
        wrap: wrap
      ))
  }

  public convenience init(
    _ text: ObservablePropertyBinding<String>,
    fontFamily: FontFamily? = nil,
    fontSize: Double? = nil,
    fontWeight: FontWeight? = nil,
    fontStyle: FontStyle? = nil,
    transform: TextTransform? = nil,
    color: Color? = nil,
    wrap: Bool? = nil
  ) {
    self.init(text)
    with(
      config: PartialConfig(
        fontConfig: PartialFontConfig(
          family: fontFamily,
          size: fontSize,
          weight: fontWeight,
          style: fontStyle
        ),
        transform: transform,
        color: color,
        wrap: wrap
      ))
  }

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

    // fix glitches that create unnecessary line breaks, probably because floating point inprecisions
    // might need to be larger
    textBoundsSize.width += 4

    return constraints.constrain(textBoundsSize)
  }

  /*override public func performLayout() {
        var preferredSize = DSize2.zero

        let transformedText = config.transform.apply(to: text)

        if transformedText.isEmpty {

            preferredSize.height = context!.getTextBoundsSize(" ", fontConfig: config.fontConfig).height

        } else {

            if config.wrap {
                preferredSize = context!.getTextBoundsSize(transformedText, fontConfig: config.fontConfig, maxWidth: constraints!.maxWidth)
            } else {
                preferredSize = context!.getTextBoundsSize(transformedText, fontConfig: config.fontConfig)
            }
        }

        // fix glitches that create unnecessary line breaks, probably because floating point inprecisions
        // might need to be larger
        preferredSize.width += 4

        bounds.size = constraints!.constrain(preferredSize)
    }*/

  /// This function is used in TextInput to get the coordinates where the caret should be displayed.
  /// - Returns: The local bounding rect (origin: self -> topLeft) up to (including) the specified index inside the text.
  /// - Parameter to: Up to which character index (including the index) to return the bounds.
  /// - Misc:
  /// TODO: maybe put this somewhere else
  public func getSubBounds(to index: Int) -> DRect {
    var preferredSize = DSize2.zero
    let partialText = String(text[..<text.index(text.startIndex, offsetBy: index)])
    let transformedText = config.transform.apply(to: partialText)

    if transformedText.isEmpty {
      preferredSize.height = context.getTextBoundsSize(" ", fontConfig: config.fontConfig).height
    } else {
      if config.wrap {
        preferredSize = context.getTextBoundsSize(
          transformedText, fontConfig: config.fontConfig, maxWidth: previousConstraints!.maxWidth)
      } else {
        preferredSize = context.getTextBoundsSize(transformedText, fontConfig: config.fontConfig)
      }
    }

    return DRect(min: .zero, max: DVec2(preferredSize))
  }

  override public func renderContent() -> RenderObject? {
    TextRenderObject(
      config.transform.apply(to: text), fontConfig: config.fontConfig, color: config.color,
      topLeft: globalPosition, maxWidth: config.wrap ? bounds.size.width : nil)
  }
}

extension Text {
  public struct PartialConfig: PartialConfigProtocol {
    public var fontConfig: PartialFontConfig?
    public var transform: TextTransform?
    public var color: Color?
    public var wrap: Bool?

    public init() {
    }

    public init(
      fontConfig: PartialFontConfig? = nil,
      transform: TextTransform? = nil,
      color: Color? = nil,
      wrap: Bool? = nil
    ) {
      self.fontConfig = fontConfig
      self.transform = transform
      self.color = color
      self.wrap = wrap
    }

    public static func merged(partials: [PartialConfig]) -> PartialConfig {
      var result = Self()
      var fontConfigs = [PartialFontConfig]()
      for partial in partials.reversed() {
        if let partial = partial.fontConfig {
          fontConfigs.append(partial)
        }
        result.transform = partial.transform ?? result.transform
        result.color = partial.color ?? result.color
        result.wrap = partial.wrap ?? result.wrap
      }
      result.fontConfig = PartialFontConfig(partials: fontConfigs)
      return result
    }
  }

  public struct Config: ConfigProtocol, Hashable {
    public typealias PartialConfig = Text.PartialConfig
    public var fontConfig: FontConfig
    public var transform: TextTransform
    public var color: Color
    public var wrap: Bool

    public init(fontConfig: FontConfig, transform: TextTransform, color: Color, wrap: Bool) {
      self.fontConfig = fontConfig
      self.transform = transform
      self.color = color
      self.wrap = wrap
    }

    public func merged(with partialConfig: PartialConfig?) -> Self {
      var result = self
      result.fontConfig = FontConfig(
        partial: partialConfig?.fontConfig, default: defaultConfig.fontConfig)
      result.transform = partialConfig?.transform ?? defaultConfig.transform
      result.color = partialConfig?.color ?? defaultConfig.color
      result.wrap = partialConfig?.wrap ?? defaultConfig.wrap
      return result
    }
  }
}
