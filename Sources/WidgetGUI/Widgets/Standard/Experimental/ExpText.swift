import ExperimentalReactiveProperties
import VisualAppBase
import GfxMath

extension Experimental {
  public class Text: Widget, ExperimentalStylableWidget {
    @ObservableProperty
    private var text: String

    private var color: Color {
      stylePropertyValue(StyleKeys.textColor, as: Color.self) ?? Color.black
    }
    private var transform: TextTransform {
      stylePropertyValue(StyleKeys.textTransform, as: TextTransform.self) ?? TextTransform.none
    }
    private var wrap: Bool {
      stylePropertyValue(StyleKeys.wrapText, as: Bool.self) ?? false
    }
    private var fontConfig: FontConfig {
      FontConfig(
        family: defaultFontFamily,
        size: stylePropertyValue(StyleKeys.fontSize, as: Double.self) ?? 12,
        weight: stylePropertyValue(StyleKeys.fontWeight, as: FontWeight.self) ?? .regular,
        style: stylePropertyValue(StyleKeys.fontStyle, as: FontStyle.self) ?? .normal
      )
    }

    private var transformedText: String {
      transform.apply(to: text)
    }

    public init<P: ReactiveProperty>(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> Experimental.StyleProperties = { _ in [] },
      _ textProperty: P) where P.Value == String {
        super.init()

        if let classes = classes {
          self.classes = classes
        }
        self.with(stylePropertiesBuilder(StyleKeys.self))

        self._text.bind(textProperty)
    }

    public init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> Experimental.StyleProperties = { _ in [] },
      _ text: String) {
        super.init()
        
        if let classes = classes {
          self.classes = classes
        }
        self.with(stylePropertiesBuilder(StyleKeys.self))

        self._text.bind(StaticProperty(text))
    }

    override public func getBoxConfig() -> BoxConfig {
      var boxConfig = BoxConfig(
        preferredSize: context.getTextBoundsSize(transformedText, fontConfig: fontConfig))

      if wrap {
        boxConfig.minSize = boxConfig.preferredSize
      }

      return boxConfig
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      let boundedText = transformedText.isEmpty ? " " : transformedText

      var textBoundsSize = context.getTextBoundsSize(
        boundedText, fontConfig: fontConfig, maxWidth: wrap ? constraints.maxWidth : nil
      )
      
      if transformedText.isEmpty {
        textBoundsSize.width = 0
      }

      // fix glitches that create unnecessary line breaks, probably because floating point inprecisions
      // might need to be larger
      textBoundsSize.width += 4

      return constraints.constrain(textBoundsSize)
    }

    override public func renderContent() -> RenderObject? {
      let maxWidth = wrap ? bounds.size.width : nil

      if let previousContent = renderState.mainContent as? TextRenderObject {
        previousContent.text = transformedText
        previousContent.fontConfig = fontConfig
        previousContent.color = color
        previousContent.topLeft = globalPosition
        previousContent.maxWidth = maxWidth
        return previousContent
      } else {
        return TextRenderObject(
          transformedText, fontConfig: fontConfig, color: color,
          topLeft: globalPosition, maxWidth: maxWidth)
      }
    }

    public enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case textColor
      case textTransform
      case wrapText
      case fontSize
      case fontWeight
      case fontStyle
    }
  }
}