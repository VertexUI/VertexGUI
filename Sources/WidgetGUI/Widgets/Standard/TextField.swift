import VisualAppBase
import CustomGraphicsMath

public final class TextField: Widget, ConfigurableWidget {
    public struct Config: WidgetGUI.Config {
        public var backgroundConfig: Background.Config
        public var textInputConfig: TextInput.PartialConfig

        public init(backgroundConfig: Background.Config, textInputConfig: TextInput.PartialConfig) {
            self.backgroundConfig = backgroundConfig
            self.textInputConfig = textInputConfig
        }

        public init(partial partialConfig: PartialConfig?, default defaultConfig: Config) {
            self.backgroundConfig = partialConfig?.backgroundConfig ?? defaultConfig.backgroundConfig
            self.textInputConfig = TextInput.PartialConfig.merged(partials: [partialConfig?.textInputConfig, defaultConfig.textInputConfig].compactMap { $0 })
        }
    }

    public struct PartialConfig: WidgetGUI.PartialConfig {
        public var backgroundConfig: Background.Config?
        public var textInputConfig: TextInput.PartialConfig?

        public init() {}

        public init(backgroundConfig: Background.Config? = nil, textInputConfig: TextInput.PartialConfig? = nil) {
            self.backgroundConfig = backgroundConfig
            self.textInputConfig = textInputConfig
        }
    }

    public static let defaultConfig = Config(
        backgroundConfig: Background.Config(fill: .Blue, shape: .Rectangle),
        textInputConfig: TextInput.PartialConfig())

    public var localPartialConfig: PartialConfig?
    public var localConfig: Config?
    lazy public var config: Config = combineConfigs()

    lazy private var textInput = TextInput()

    public internal(set) var onTextChanged = EventHandlerManager<String>()
    
    public init(_ initialText: String = "", onTextChanged textChangedHandler: ((String) -> ())? = nil) {
        super.init()
        textInput.text = initialText
        if let handler = textChangedHandler {
            _ = onDestroy(onTextChanged(handler))
        }
    }

    override public func build() {
        _ = onDestroy(textInput.onTextChanged { [unowned self] in
            onTextChanged.invokeHandlers($0)
        })
        
        textInput.with(config: config.textInputConfig)

        children = [
            Background {
                Padding(all: 16) {
                    textInput
                }
            }.with(config: config.backgroundConfig)
        ]
    }

    override public func performLayout() {
        let child = children[0]
        child.constraints = constraints
        child.layout()
        bounds.size = child.bounds.size
    }
}