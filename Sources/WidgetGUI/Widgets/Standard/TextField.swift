import VisualAppBase
import CustomGraphicsMath

public class TextField: Widget {
    public struct Config {
        public var backgroundConfig: Background.Config
        public var textInputConfig: TextInput.Config

        public init(backgroundConfig: Background.Config, textInputConfig: TextInput.Config) {
            self.backgroundConfig = backgroundConfig
            self.textInputConfig = textInputConfig
        }

        public init(partials: [PartialConfig], defaultConfig: Config) {
            var backgroundConfig: Background.Config?
            var textInputConfigs: [TextInput.PartialConfig] = []
            for partial in partials {
                backgroundConfig = partial.backgroundConfig ?? backgroundConfig
                if let partialConfig = partial.textInputConfig {
                    textInputConfigs.append(partialConfig)
                }
            }
            self.backgroundConfig = backgroundConfig ?? defaultConfig.backgroundConfig
            self.textInputConfig = TextInput.Config(partials: textInputConfigs, default: defaultConfig.textInputConfig)
        }
    }

    public struct PartialConfig {
        public var backgroundConfig: Background.Config?
        public var textInputConfig: TextInput.PartialConfig?
    }

    public static let defaultConfig = Config(
        backgroundConfig: Background.Config(fill: .Blue, shape: .Rectangle),
        textInputConfig: TextInput.defaultConfig)

    private var config: Config

    lazy private var textInput = TextInput(config: config.textInputConfig)
    
    public init(_ initialText: String = "", config: PartialConfig? = nil, onTextChanged textChangedHandler: ((String) -> ())? = nil) {
        self.config = config != nil ? Config(partials: [config!], defaultConfig: Self.defaultConfig) : Self.defaultConfig
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