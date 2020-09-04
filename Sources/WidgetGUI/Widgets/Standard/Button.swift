import Foundation
import CustomGraphicsMath
import VisualAppBase
import Runtime

public final class Button: SingleChildWidget, StatefulWidget, ConfigurableWidget {

    public enum State {

        case Normal, Hover, Active
    }

    public struct StateStyle: WidgetGUI.Config {

        public typealias PartialConfig = Button.PartialStateStyle

        public var backgroundConfig: Background.PartialConfig

        public var textConfig: Text.PartialConfig

        public init(backgroundConfig: Background.PartialConfig, textConfig: Text.PartialConfig) {

            self.backgroundConfig = backgroundConfig

            self.textConfig = textConfig
        }

        /*public init(partial partialConfig: PartialStateStyle?, default defaultConfig: Self) {
            self.backgroundConfig = Background.PartialConfig.merged(partials: [partialConfig?.backgroundConfig, defaultConfig.backgroundConfig].compactMap { $0 })
            self.textConfig = Text.PartialConfig.merged(partials: [partialConfig?.textConfig, defaultConfig.textConfig].compactMap { $0 })
        }*/
    }

    public struct PartialStateStyle: WidgetGUI.PartialConfig {

        public var backgroundConfig: Background.PartialConfig = Background.PartialConfig()

        public var textConfig: Text.PartialConfig = Text.PartialConfig()

        public init() {}
    }

    public struct Config: WidgetGUI.Config {

        public typealias PartialConfig = Button.PartialConfig

        public var normalStyle: StateStyle
        
        public var hoverStyle: StateStyle

        public var activeStyle: StateStyle

        public init(normalStyle: StateStyle, hoverStyle: StateStyle, activeStyle: StateStyle) {

            self.normalStyle = normalStyle

            self.hoverStyle = hoverStyle

            self.activeStyle = activeStyle
        }

        /*public init(partial partialConfig: PartialConfig?, default defaultConfig: Self) {
            self.normalStyle = StateStyle(partial: partialConfig?.normalStyle, default: defaultConfig.normalStyle)
            self.hoverStyle = /*partialConfig?.hoverStyle ??*/ defaultConfig.hoverStyle
            self.activeStyle = /*partialConfig?.activeStyle ??*/ defaultConfig.activeStyle
        }*/
    }
    
    public struct PartialConfig: WidgetGUI.PartialConfig {

        public var normalStyle: PartialStateStyle = PartialStateStyle()

        public var hoverStyle: PartialStateStyle = PartialStateStyle()

        public var activeStyle: PartialStateStyle = PartialStateStyle()

        public init() {}
    }

    public var state: State = .Normal {

        didSet {

            invalidateRenderState()
        }
    }

    private static let defaultTextConfig = Text.PartialConfig(

        fontConfig: PartialFontConfig(

            family: defaultFontFamily, size: 16, weight: .Bold, style: .Normal),

        transform: .Uppercase,

        color: .Black,
        
        wrap: false)

    public static let defaultConfig = Config(

        normalStyle: StateStyle(

            backgroundConfig: Background.PartialConfig {

                $0.fill = Color(255, 0, 0, 255)

                $0.shape = .Rectangle
            },

            textConfig: defaultTextConfig),

        hoverStyle: StateStyle(

            backgroundConfig: Background.PartialConfig {

                $0.fill = Color(0, 255, 0, 255)

                $0.shape = .Rectangle
            },

            textConfig: defaultTextConfig),

        activeStyle: StateStyle(

            backgroundConfig: Background.PartialConfig {

                $0.fill = Color(0, 0, 255, 255)

                $0.shape = .Rectangle
            },

            textConfig: defaultTextConfig))

    public var localConfig: Config?

    public var localPartialConfig: PartialConfig?

    lazy public var config = combineConfigs()
    
    public var cursorRequestId: UInt64? = nil

    public var onClick = EventHandlerManager<GUIMouseButtonClickEvent>()

    private var dropCursorRequest: (() -> ())?

    private var childBuilder: () -> Widget

    public init(

        @WidgetBuilder child childBuilder: @escaping () -> Widget,

        onClick onClickHandler: EventHandlerManager<GUIMouseButtonClickEvent>.Handler? = nil) {

            if onClickHandler != nil {

                _ = onClick.addHandler(onClickHandler!)
            }

            self.childBuilder = childBuilder
    }

    public convenience init(@WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.init(child: childBuilder, onClick: nil)
    }

    override public func buildChild() -> Widget {

        MouseArea {

            Background {

                Padding(all: 16) { [unowned self] in

                    TextConfigProvider(config: config.normalStyle.textConfig) {

                        childBuilder()
                    }
                }

            }.with(config: config.normalStyle.backgroundConfig)

        } onClick: { [unowned self] in

            onClick.invokeHandlers($0)

        } onMouseEnter: { [unowned self] _ in

            state = .Hover

            // TODO: might need to implement cursor via render object and check in RenderObjectTree renderer which renderobject below mouse
            dropCursorRequest = context!.requestCursor(.Hand)

        } onMouseLeave: { [unowned self] _ in

            state = .Normal

            dropCursorRequest!()
        }
    }

    public func forwardOnClick(_ event: GUIMouseButtonClickEvent) {

        onClick.invokeHandlers(event)
    }

    override public func renderContent() -> RenderObject? {

        let style: StateStyle

        switch state {

        case .Normal:

            style = config.normalStyle

        case .Hover:

            style = config.hoverStyle

        case .Active:

            style = config.activeStyle
        }

        return RenderObject.Container {
            /*if state == .Normal {
                RenderObject.RenderStyle(
                    fillColor: FixedRenderValue(Color(0, 255, 120, 255))) {
                        RenderObject.Rectangle(globalBounds)
                }
            } else if state == .Hover {
                RenderObject.RenderStyle(
                    fillColor: TimedRenderValue(
                        id: 0, 
                        startTimestamp: Date.timeIntervalSinceReferenceDate, 
                        duration: 3,
                        valueAt: { progress in Color(UInt8(progress * 255), 0, 0, 255) })) {
                    RenderObject.Rectangle(globalBounds)
                }
            }*/
            child.render() 
        }
    }

    override public func destroySelf() {

        onClick.removeAllHandlers()

        if let drop = dropCursorRequest {

            drop()
        }
    }
}
