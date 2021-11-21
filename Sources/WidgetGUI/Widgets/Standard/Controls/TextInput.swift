import GfxMath
import Foundation
import SkiaKit
import OpenCombine
import Drawing

public final class TextInput: ComposedWidget
{
  @MutableBinding public var text: String
  private var textBuffer: String

  @State private var placeholderText: String

  @State private var placeholderVisibility: Visibility = .visible

  @State private var textTranslation: DVec2 = .zero
  /*@State
  private var caretPositionTransforms: [DTransform2]*/

  @Reference private var stackContainer: Container
  @Reference private var textWidget: Text
  @Reference private var caretWidget: Drawing

  @StyleProperty public var caretColor: GfxMath.Color = .lightBlue

  private var caretIndex: Int = 2
  private var caretWidth: Double = 2

  private var caretBlinkDuration: Double = 0.9
  private var caretBlinkProgress: Double {
    let raw = Date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: caretBlinkDuration) / caretBlinkDuration
    if raw < 0.3 {
      return 1 - raw / 0.3
    } else if raw < 0.8 {
      return (raw - 0.3) / 0.5
    } else {
      return 1
    }
  }

  private var dropCursorRequest: (() -> ())? = nil

  private var textSubscription: AnyCancellable?

  public init(
    text textBinding: MutableBinding<String>,
    placeholder: String = "") {
        
      self._text = textBinding
      self.textBuffer = textBinding.value
      self.placeholderText = placeholder

      super.init()

      updatePlaceholderVisibility()

      textSubscription = self._text.publisher.sink { [unowned self] in
        textBuffer = $0
        if caretIndex > textBuffer.count {
          caretIndex = textBuffer.count
        }
        updatePlaceholderVisibility()
      }

      _ = onKeyDown(handleKeyDown)
      _ = onTextInput(handleTextInput)
  }

  private func updatePlaceholderVisibility() {
    if text.isEmpty {
      placeholderVisibility = .visible
    } else if !text.isEmpty {
      placeholderVisibility = .hidden
    }
  }

  @Compose override public var content: ComposedContent {
    Container().withContent {
      Text($text.immutable).with(classes: ["text"]).with(styleProperties: {
        (\.$transform, ImmutableBinding($textTranslation.immutable, get: {
          [DTransform2.translate($0)]
        }))
      }).connect(ref: $textWidget)

      Text($placeholderText.immutable).with(classes: ["placeholder"]).with(styleProperties: {
        (\.$visibility, $placeholderVisibility.immutable)
      })
      
      Drawing(draw: drawCaret).with(styleProperties: {
        (\.$width, 0)
        (\.$height, 0)
        (\.$opacity, ImmutableBinding($focused.immutable, get: { $0 ? 1 : 0 }))
        (\.$transform, ImmutableBinding($textTranslation.immutable, get: {
          [DTransform2.translate($0)]
        }))
      }).connect(ref: $caretWidget)
    }.connect(ref: $stackContainer).onClick { [unowned self] in
      handleClick($0)
    }
  }

  override public var style: Style {
    Style("&") {
      (\.$padding, Insets(top: 16, right: 0, bottom: 16, left: 0))
      (\.$fontSize, 16)
    } nested: {

      Style("& Container", Container.self) {
        (\.$layout, AbsoluteLayout.self)
        (\.$overflowX, .cut)
      }

      Style(".placeholder") {
        (\.$opacity, 0.5)
        (\.$visibility, $placeholderVisibility.immutable)
      }
    }
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    stackContainer.layout(constraints: constraints)
    return stackContainer.layoutedSize
  }

  private func syncText() {
    text = textBuffer
  }

  private func handleClick(_ event: GUIMouseButtonClickEvent) {
    requestFocus()

    let localX = event.position.x - stackContainer.globalPosition.x - textTranslation.x
    var maxIndexBelowX = 0
    var previousSubstringSize = DSize2.zero

    for i in 0..<text.count {
      let currentSubstringSize = textWidget.measureText(String(text.prefix(i + 1))).size
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

  public func handleKeyDown(_ event: GUIKeyDownEvent) {
    switch event.key {
    case .backspace:
      if caretIndex > 0 && textBuffer.count >= caretIndex {
        textBuffer.remove(
          at: textBuffer.index(textBuffer.startIndex, offsetBy: caretIndex - 1))
        caretIndex -= 1
        syncText()
        updateTextTranslation()
      }
    case .delete:
      if caretIndex < textBuffer.count {
        textBuffer.remove(at: textBuffer.index(textBuffer.startIndex, offsetBy: caretIndex))
        syncText()
      }
    case .arrowLeft:
      if caretIndex > 0 {
        caretIndex -= 1
        updateTextTranslation()
      }
    case .arrowRight:
      if caretIndex < textBuffer.count {
        caretIndex += 1
        updateTextTranslation()
      }
    default:
      break
    }
  }

  public func handleTextInput(_ event: GUITextInputEvent) {
    textBuffer.insert(
      contentsOf: event.text,
      at: textBuffer.index(textBuffer.startIndex, offsetBy: caretIndex))
    caretIndex += event.text.count
    syncText()
    updateTextTranslation()
  }

  private func updateTextTranslation() {
    let caretPositionX = textWidget.measureText(String(text.prefix(caretIndex))).width
    if caretPositionX > stackContainer.layoutedSize.width {
      let nextCharX = textWidget.measureText(String(text.prefix(caretIndex + 1))).width
      let currentCharWidth = nextCharX - caretPositionX
      let extraGap = stackContainer.layoutedSize.width * 0.1
      textTranslation = DVec2(-caretPositionX + stackContainer.layoutedSize.width - currentCharWidth - extraGap, 0)
    } else if caretPositionX + textTranslation.x < 0 {
      textTranslation = DVec2(-caretPositionX, 0)
    }
  }

  public func drawCaret(_ canvas: Canvas) {
    let caretHeight = fontSize
    let caretTranslationX = textWidget.measureText(String(text.prefix(caretIndex))).width + caretWidth / 2

    canvas.drawLine(
      from: DVec2(caretTranslationX, textWidget.layoutedSize.height / 2 - caretHeight / 2),
      to: DVec2(caretTranslationX, textWidget.layoutedSize.height / 2 + caretHeight / 2),
      paint: Paint.stroke(
        color: caretColor.adjusted(alpha: UInt8(caretBlinkProgress * 255)),
        width: caretWidth))
  }

  override public func destroySelf() {
    if let drop = dropCursorRequest {
      drop()
    }
  }
}