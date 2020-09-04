import VisualAppBase
import CustomGraphicsMath

public final class TextField: SingleChildWidget, ConfigurableWidget {

    public struct Config: WidgetGUI.Config {

        public typealias PartialConfig = TextField.PartialConfig

        public var backgroundConfig: Background.PartialConfig
        
        public var textInputConfig: TextInput.PartialConfig

        public init(backgroundConfig: Background.PartialConfig, textInputConfig: TextInput.PartialConfig) {
            
            self.backgroundConfig = backgroundConfig

            self.textInputConfig = textInputConfig
        }
    }

    public struct PartialConfig: WidgetGUI.PartialConfig {

        public var backgroundConfig = Background.PartialConfig()

        public var textInputConfig = TextInput.PartialConfig()

        public init() {}
    }

    public static let defaultConfig = Config(

        backgroundConfig: Background.PartialConfig {

            $0.fill = Color(230, 230, 230, 255)

            $0.shape = .Rectangle
        },

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

    override public func buildChild() -> Widget {

        _ = onDestroy(textInput.onTextChanged { [unowned self] in

            onTextChanged.invokeHandlers($0)
        })
        
        textInput.with(config: config.textInputConfig)

        return Border(bottom: 3, color: .Blue) { [unowned self] in

            Background {

                Clip {

                    Padding(top: 8, right: 16, bottom: 8, left: 16) {

                        textInput
                    }
                }

            }.with(config: config.backgroundConfig)
        }
    }

    override public func renderContent() -> RenderObject? {
        
        // TODO: handling clipping like this will allow the text to enter the border of the TextField, maybe add a Clip Widget in buildChild
        RenderObject.Clip(globalBounds) {

            child.render()
        }
    }
}