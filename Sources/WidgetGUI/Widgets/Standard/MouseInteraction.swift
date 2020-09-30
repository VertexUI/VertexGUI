// TODO: find a better name, maybe; sounds too similar to MouseArea / Why need both even?
public final class MouseInteraction: SingleChildWidget, GUIMouseEventConsumer, ConfigurableWidget {

    private var state: State = .Normal

    lazy public var config: Config = combineConfigs()

    public var localConfig: Config? = nil

    public var localPartialConfig: PartialConfig? = nil
    
    public static var defaultConfig: Config {

        Config(stateConfigs: [:])
    }

    private let childBuilder: () -> Widget

    public init(@WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.childBuilder = childBuilder
    }

    override public func buildChild() -> Widget {

        let stateConfig = config.stateConfigs[state]

        return ConfigProvider(stateConfig != nil ? [stateConfig!] : []) { [unowned self] in

            childBuilder()
        }
    }

    public func consume(_ event: GUIMouseEvent) {

        switch event {

        case _ as GUIMouseEnterEvent:

            self.state = .Hover

        case _ as GUIMouseLeaveEvent:

            self.state = .Normal

        case _ as GUIMouseButtonDownEvent:

            self.state = .Active

        case _ as GUIMouseButtonUpEvent:

            if globalBounds.contains(point: event.position) {

                self.state = .Hover

            } else {

                self.state = .Normal
            }

        default:

            return
        }

        invalidateChild()
    }
}

extension MouseInteraction {
    
    public enum State {

        case Normal

        case Hover

        case Active
    }

    public struct Config: ConfigProtocol {

        public typealias PartialConfig = MouseInteraction.PartialConfig

        public var stateConfigs: [State: PartialConfigMarkerProtocol]
    }

    public struct PartialConfig: PartialConfigProtocol {

        public var stateConfigs: [State: PartialConfigMarkerProtocol] = [:]

        public init() {}
    }
}