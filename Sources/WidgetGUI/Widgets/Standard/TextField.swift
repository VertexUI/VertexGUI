import GfxMath
import VisualAppBase

public final class TextField: SingleChildWidget, ConfigurableWidget {
  public static let defaultConfig = Config(
    backgroundConfig: Background.PartialConfig {
      $0.fill = Color(230, 230, 230, 255)
      $0.shape = .Rectangle
    },
    textInputConfig: TextInput.PartialConfig(),
    borderColor: .Blue)
  public var localPartialConfig: PartialConfig?
  public var localConfig: Config?
  lazy public var config: Config = combineConfigs()

  @MutableProperty
  public var text: String

  @Reference
  private var textInput: TextInput

  //public internal(set) var onTextChanged = WidgetEventHandlerManager<Observabl>()

  public init(
    _ initialText: String = "", onTextChanged textChangedHandler: ((String) -> Void)? = nil
  ) {
    self.text = initialText
    super.init()
    /*if let handler = textChangedHandler {
      _ = onDestroy(onTextChanged(handler))
    }*/
    /*_ = onDestroy(_text.onChanged { [unowned self] in
      onTextChanged.invokeHandlers($0)
    })*/
  }

  public init(bind mutableText: MutableProperty<String>) {
    self._text = mutableText
    super.init()
    /*_ = onDestroy(_text.onChanged { [unowned self] in
      onTextChanged.invokeHandlers($0)
    })*/
  }

  override public func buildChild() -> Widget {
    ConfigProvider([
      config.backgroundConfig
    ]) { [unowned self] in
      Border(bottom: 3, color: config.borderColor) {
        Background {
          Clip {
            Padding(top: 8, right: 16, bottom: 8, left: 16) {
              TextInput(bind: $text).with(config: config.textInputConfig).connect(ref: $textInput)
            }
          }
        }
      }
    }
  }

  override public func getBoxConfig() -> BoxConfig {
    let childConfig = child.boxConfig
    return BoxConfig(preferredSize: childConfig.preferredSize, minSize: .zero, maxSize: .infinity)
  }

  @discardableResult
  override public func requestFocus() -> Self {
    // TODO: maybe have a better way to request focus on this?
    // TODO: maybe parent should get focus and only if parent has focus a child can have focus (focus context?)
    if mounted {
      textInput.requestFocus()
    } else {
      _ = onMounted.once { [unowned self] in
        textInput.requestFocus()
      }
    }
    return self
  }

  override public func renderContent() -> RenderObject? {
    // TODO: handling clipping like this will allow the text to enter the border of the TextField, maybe add a Clip Widget in buildChild
    RenderObject.Clip(globalBounds) {
      child.render()
    }
  }
}

extension TextField {
  public struct Config: ConfigProtocol {
    public typealias PartialConfig = TextField.PartialConfig
    public var backgroundConfig: Background.PartialConfig
    public var textInputConfig: TextInput.PartialConfig
    public var borderColor: Color

    public init(
      backgroundConfig: Background.PartialConfig, textInputConfig: TextInput.PartialConfig, borderColor: Color
    ) {
      self.backgroundConfig = backgroundConfig
      self.textInputConfig = textInputConfig
      self.borderColor = borderColor
    }
  }

  public struct PartialConfig: PartialConfigProtocol {
    public var backgroundConfig = Background.PartialConfig()
    public var textInputConfig = TextInput.PartialConfig()
    public var borderColor: Color? = nil
    public init() {}
  }
}