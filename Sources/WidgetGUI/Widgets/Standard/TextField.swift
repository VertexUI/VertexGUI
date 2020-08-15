import VisualAppBase
import CustomGraphicsMath

public class TextField: Widget {
    public struct Config {
        public var backgroundConfig: Background.Config
        public var textInputConfig: TextInput.PartialConfig

        public init(backgroundConfig: Background.Config, textInputConfig: TextInput.PartialConfig) {
            self.backgroundConfig = backgroundConfig
            self.textInputConfig = textInputConfig
        }

        public init(partial partialConfig: PartialConfig?, default defaultConfig: Config) {
            self.backgroundConfig = partialConfig?.backgroundConfig ?? defaultConfig.backgroundConfig
            self.textInputConfig = TextInput.PartialConfig(partials: [partialConfig?.textInputConfig, defaultConfig.textInputConfig].compactMap { $0 })
        }
    }

    public struct PartialConfig {
        public var backgroundConfig: Background.Config?
        public var textInputConfig: TextInput.PartialConfig?

        public init(backgroundConfig: Background.Config? = nil, textInputConfig: TextInput.PartialConfig? = nil) {
            self.backgroundConfig = backgroundConfig
            self.textInputConfig = textInputConfig
        }

        public init(partials: [PartialConfig]) {
            var textInputConfigs = [TextInput.PartialConfig]()
            
            for partial in partials.reversed() {

                self.backgroundConfig = partial.backgroundConfig ?? self.backgroundConfig

                if let partial = partial.textInputConfig {
                    textInputConfigs.append(partial)
                }
            }

            self.textInputConfig = TextInput.PartialConfig(partials: textInputConfigs)            
        }
    }

    public static let defaultConfig = Config(
        backgroundConfig: Background.Config(fill: .Blue, shape: .Rectangle),
        textInputConfig: TextInput.PartialConfig())

    private var config: Config

    lazy private var textInput = TextInput().with(config: config.textInputConfig)
    
    public init(_ initialText: String = "", config: PartialConfig? = nil, onTextChanged textChangedHandler: ((String) -> ())? = nil) {
        self.config = Config(partial: config, default: Self.defaultConfig)
        super.init()
        textInput.text = initialText
        if let handler = textChangedHandler {
            _ = onDestroy(textInput.onTextChanged(handler))
        }
    }

    override public func build() {
        children = [
            Background(config: config.backgroundConfig) {
                Padding(all: 8) {
                    textInput
                }
            }
        ]
    }

    override public func performLayout() {
        let child = children[0]
        child.constraints = constraints
        child.layout()
        bounds.size = child.bounds.size
    }

    /*override public func renderContent() -> RenderObject? {
        RenderObject.Container {
            for child in children {
                child.render()
            }
        }
    }*/
}