import GfxMath
import Foundation
import VisualAppBase
import ExperimentalReactiveProperties

extension Experimental {
  public final class TextInput: Widget, ExperimentalStylableWidget, GUIKeyEventConsumer, GUITextEventConsumer
  {
    @ExperimentalReactiveProperties.MutableProperty
    public var text: String
    private var textBuffer: String

    @ExperimentalReactiveProperties.ObservableProperty
    private var placeholderText: String

    @ExperimentalReactiveProperties.MutableProperty
    private var placeholderVisibility: Visibility = .visible

    @Reference
    private var containerWidget: Experimental.Container
    @Reference
    private var stackContainer: Experimental.Stack
    @Reference
    private var textWidget: Experimental.Text
    @Reference
    private var caretWidget: Experimental.Drawing

    private var caretIndex: Int = 2
    private var lastDrawTimestamp: Double = 0.0
    private var caretWidth: Double = 2
    private var caretBlinkDuration: Double = 0.9
    private var caretBlinkTime = 0.0 {
      didSet {
        caretBlinkTime = caretBlinkTime.truncatingRemainder(dividingBy: caretBlinkDuration)
      }
    }
    private var caretBlinkProgress: Double {
      let raw = caretBlinkTime / caretBlinkDuration
      if raw < 0.3 {
        return 1 - raw / 0.3
      } else if raw < 0.8 {
        return (raw - 0.3) / 0.5
      } else {
        return 1
      }
    }

    private var dropCursorRequest: (() -> ())? = nil

    public init<T: MutablePropertyProtocol, P: ReactiveProperty>(
      classes: [String]? = nil,
      @StylePropertiesBuilder styleProperties stylePropertiesBuilder: (TextInput.StyleKeys.Type) -> StyleProperties = { _ in [] },
      mutableText mutableTextProperty: T,
      placeholder placeholderProperty: P? = nil) where T.Value == String, P.Value == String {

        if mutableTextProperty.hasValue {
          self.textBuffer = mutableTextProperty.value
        } else {
          self.textBuffer = ""
        }
        self.text = self.textBuffer

        super.init()

        if let property = placeholderProperty {
          self.$placeholderText.bind(property)
        } else {
          self.$placeholderText.bind(StaticProperty(""))
        }

        if let classes = classes {
          self.classes.append(contentsOf: classes)
        }
        self.with(stylePropertiesBuilder(StyleKeys.self))

        updatePlaceholderVisibility()

        self.$text.bindBidirectional(mutableTextProperty)
        _ = self.$text.onChanged { [unowned self] in
          textBuffer = $0.new
          updatePlaceholderVisibility()
        }

        self.focusable = true
    }

    public convenience init<T: MutablePropertyProtocol>(
      classes: [String]? = nil,
      @StylePropertiesBuilder styleProperties stylePropertiesBuilder: (TextInput.StyleKeys.Type) -> StyleProperties = { _ in [] },
      mutableText mutableTextProperty: T) where T.Value == String {

        self.init(classes: classes, styleProperties: stylePropertiesBuilder, mutableText: mutableTextProperty, placeholder: Optional<ObservableProperty<String>>.none)
    }

    public convenience init<T: MutablePropertyProtocol>(
      classes: [String]? = nil,
      @StylePropertiesBuilder styleProperties stylePropertiesBuilder: (TextInput.StyleKeys.Type) -> StyleProperties = { _ in [] },
      mutableText mutableTextProperty: T,
      placeholder: String) where T.Value == String {

        self.init(classes: classes, styleProperties: stylePropertiesBuilder, mutableText: mutableTextProperty, placeholder: StaticProperty(placeholder))
    }

    private func updatePlaceholderVisibility() {
      if text.isEmpty && placeholderVisibility == .hidden {
        placeholderVisibility = .visible
      } else if !text.isEmpty && placeholderVisibility == .visible {
        placeholderVisibility = .hidden
      }
    }

    override public func performBuild() {
      children = [
        Experimental.Container(styleProperties: {
          ($0.width, stylePropertyValue(reactive: StyleKeys.width))
          ($0.height, stylePropertyValue(reactive: StyleKeys.height))
          ($0.backgroundFill, stylePropertyValue(reactive: StyleKeys.backgroundFill))
          ($0.borderWidths, stylePropertyValue(reactive: StyleKeys.borderWidths))
          ($0.borderColor, stylePropertyValue(reactive: StyleKeys.borderColor))
        }) { [unowned self] in
          Experimental.Stack {
            Experimental.Text(styleProperties: {
              ($0.textColor, Color.white)
              ($0.fontSize, 24.0)
            }, $text).connect(ref: $textWidget)
            Experimental.Text(styleProperties: {
              ($0.opacity, 0.5)
              ($0.textColor, Color.white)
              ($0.fontSize, 24.0)
              ($0.visibility, $placeholderVisibility)
            }, $placeholderText)
          }.connect(ref: $stackContainer)
        }.connect(ref: $containerWidget).onClick { [unowned self] in
          self.handleClick($0)
        },
        Experimental.Drawing(draw: self.drawCaret).connect(ref: $caretWidget)
      ]
    }

    override public func getContentBoxConfig() -> BoxConfig {
      containerWidget.boxConfig
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      containerWidget.layout(constraints: constraints)
      caretWidget.layout(constraints: BoxConstraints(size: containerWidget.size))
      return constraints.constrain(containerWidget.size)
    }

    private func syncText() {
      text = textBuffer
    }

    private func handleClick(_ event: GUIMouseButtonClickEvent) {
      requestFocus()

      let localX = event.position.x - textWidget.globalPosition.x
      var maxIndexBelowX = 0
      var previousSubstringSize = DSize2.zero

      for i in 0..<text.count {
        let currentSubstringSize = textWidget.measureText(String(text.prefix(i + 1)))
        let currentLetterMiddleX = previousSubstringSize.x + (currentSubstringSize.x - previousSubstringSize.x) / 2

        if localX > currentLetterMiddleX {
          maxIndexBelowX = i + 1
        } else {
          break
        }

        previousSubstringSize = currentSubstringSize
      }

      caretIndex = maxIndexBelowX
    }

    public func consume(_ event: GUIMouseEvent) {
      if event is GUIMouseEnterEvent {
        dropCursorRequest = context.requestCursor(.Text)
      } else if event is GUIMouseLeaveEvent {
        if let drop = dropCursorRequest {
          drop()
        }
      }
    }

    public func consume(_ event: GUIKeyEvent) {
      if let event = event as? GUIKeyDownEvent {
        switch event.key {
        case .Backspace:
          if caretIndex > 0 && textBuffer.count >= caretIndex {
            invalidateRenderState {
              textBuffer.remove(
                at: textBuffer.index(textBuffer.startIndex, offsetBy: caretIndex - 1))
              caretIndex -= 1
              syncText()
            }
          }
        case .Delete:
          if caretIndex < textBuffer.count {
            invalidateRenderState {
              textBuffer.remove(at: textBuffer.index(textBuffer.startIndex, offsetBy: caretIndex))
              syncText()
            }
          }
        case .ArrowLeft:
          if caretIndex > 0 {
            caretIndex -= 1
          }
        case .ArrowRight:
          if caretIndex < textBuffer.count {
            caretIndex += 1
          }
        default:
          break
        }
      }
    }

    public func consume(_ event: GUITextEvent) {
      if let event = event as? GUITextInputEvent {
        invalidateRenderState {
          textBuffer.insert(
            contentsOf: event.text,
            at: textBuffer.index(textBuffer.startIndex, offsetBy: caretIndex))
          caretIndex += event.text.count
          syncText()
        }
      }
    }

    public func drawCaret(_ drawingContext: DrawingContext) {
      let timestamp = context.applicationTime
      caretBlinkTime += timestamp - lastDrawTimestamp
      lastDrawTimestamp = timestamp

      var caretTranslationX = stackContainer.position.x
      caretTranslationX += textWidget.measureText(String(text.prefix(caretIndex))).width + caretWidth / 2

      drawingContext.drawLine(
        from: DVec2(caretTranslationX, textWidget.position.y),
        to: DVec2(caretTranslationX, textWidget.position.y + textWidget.height),
        paint: Paint(strokeWidth: caretWidth, strokeColor: Color.yellow.adjusted(alpha: UInt8(caretBlinkProgress * 255))))
    }

    override public func destroySelf() {
      if let drop = dropCursorRequest {
        drop()
      }
    }

    public struct StyleKeys: ExperimentalDefaultStyleKeys, ExperimentalContainerStyleKeys {
    } 
  }
}