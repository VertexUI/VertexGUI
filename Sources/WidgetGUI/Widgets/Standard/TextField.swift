import CustomGraphicsMath
import VisualAppBase

public final class TextField: SingleChildWidget, ConfigurableWidget {
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

  @Reference
  private var textInput: TextInput

  private var initialText: String

  public internal(set) var onTextChanged = WidgetEventHandlerManager<String>()

  public init(
    _ initialText: String = "", onTextChanged textChangedHandler: ((String) -> Void)? = nil
  ) {
    self.initialText = initialText
    super.init()
    if let handler = textChangedHandler {
      _ = onDestroy(onTextChanged(handler))
    }
  }

  override public func buildChild() -> Widget {
    ConfigProvider([
      config.backgroundConfig
    ]) { [unowned self] in
      Border(bottom: 3, color: config.borderColor) {
        Background {
          Clip {
            Padding(top: 8, right: 16, bottom: 8, left: 16) {
              TextInput(initialText).with(config: config.textInputConfig).with { textInput in
                // TODO: instead of doing it like this, provide a afterBuild hook in Widget and then use refs to access TextInput
                _ = onDestroy((textInput as! TextInput).$text.onChanged {
                  onTextChanged.invokeHandlers($0)
                })
              }.connect(ref: $textInput)
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
      onMounted.once { [unowned self] in
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
