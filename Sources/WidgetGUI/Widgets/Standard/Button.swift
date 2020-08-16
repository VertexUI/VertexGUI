import Foundation
import CustomGraphicsMath
import VisualAppBase

public let defaultButtonTextConfig = Text.PartialConfig(
    fontConfig: PartialFontConfig(
        family: defaultFontFamily, size: 16, weight: .Bold, style: .Normal),
    transform: .Uppercase,
    color: .Black,
    wrap: false)

public final class Button: SingleChildWidget, StatefulWidget, ConfigurableWidget {
    public enum State {
        case Normal, Hover, Active
    }

    public struct StateStyle {
        public var background: Color
    }

    public struct Config: WidgetGUI.Config {
        public var normalStyle: StateStyle
        public var hoverStyle: StateStyle
        public var activeStyle: StateStyle

        public init(normalStyle: StateStyle, hoverStyle: StateStyle, activeStyle: StateStyle) {
            self.normalStyle = normalStyle
            self.hoverStyle = hoverStyle
            self.activeStyle = activeStyle
        }

        public init(partial partialConfig: PartialConfig?, default defaultConfig: Self) {
            self.normalStyle = partialConfig?.normalStyle ?? defaultConfig.normalStyle
            self.hoverStyle = partialConfig?.hoverStyle ?? defaultConfig.hoverStyle
            self.activeStyle = partialConfig?.activeStyle ?? defaultConfig.activeStyle
        }
    }
    
    public struct PartialConfig: WidgetGUI.PartialConfig {
        public var normalStyle: StateStyle?
        public var hoverStyle: StateStyle?
        public var activeStyle: StateStyle?

        public init(normalStyle: StateStyle?, hoverStyle: StateStyle?, activeStyle: StateStyle?) {
            self.normalStyle = normalStyle
            self.hoverStyle = hoverStyle
            self.activeStyle = activeStyle
        }

        public init(partials: [Self]) {
            for partial in partials.reversed() {
                self.normalStyle = partial.normalStyle ?? self.normalStyle
                self.hoverStyle = partial.hoverStyle ?? self.hoverStyle
                self.activeStyle = partial.activeStyle ?? self.activeStyle
            }
        }
    }

    public var state: State = .Normal {
        didSet {
            invalidateRenderState()
        }
    }

    public static let defaultConfig = Config(
        normalStyle: StateStyle(background: Color(255, 0, 0, 255)),
        hoverStyle: StateStyle(background: Color(0, 255, 0, 255)),
        activeStyle: StateStyle(background: Color(0, 0, 255, 255))
    )
    public var localConfig: Config?
    public var localPartialConfig: PartialConfig?
    lazy public var config = combineConfigs()
    
    public var cursorRequestId: UInt64? = nil
    public var onClick = EventHandlerManager<GUIMouseButtonClickEvent>()

    private var dropCursorRequest: (() -> ())?

    private var inputChild: Widget

    public init(
        @WidgetBuilder _ inputChildBuilder: () -> Widget,
        onClick onClickHandler: EventHandlerManager<GUIMouseButtonClickEvent>.Handler? = nil) {
            if onClickHandler != nil {
                _ = onClick.addHandler(onClickHandler!)
            }
            self.inputChild = inputChildBuilder()
            super.init()
    }

    public convenience init(@WidgetBuilder _ inputChildBuilder: () -> Widget) {
        self.init(inputChildBuilder, onClick: nil)
    }

    override public func buildChild() -> Widget {
        MouseArea(onClick: { [unowned self] in
            onClick.invokeHandlers($0)
        }, onMouseEnter: { [unowned self] _ in
            state = .Hover
            // TODO: might need to implement cursor via render object and check in RenderObjectTree renderer which renderobject below mouse
            dropCursorRequest = context!.requestCursor(.Hand)
        }, onMouseLeave: { [unowned self] _ in
            state = .Normal
            dropCursorRequest!()
        }) {
            Padding(all: 16) { [unowned self] in
                TextConfigProvider(config: defaultButtonTextConfig) {
                    inputChild
                }
            }
        }
    }

    public func forwardOnClick(_ event: GUIMouseButtonClickEvent) throws {
        try onClick.invokeHandlers(event)
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
            if state == .Normal {
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
            }
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
