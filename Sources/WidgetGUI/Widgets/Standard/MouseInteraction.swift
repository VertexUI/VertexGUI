// TODO: find a better name, maybe; sounds too similar to MouseArea / Why need both even?
public final class MouseInteraction: SingleChildWidget, GUIMouseEventConsumer, ConfigurableWidget {

    @Observable private var state: State = .Normal

    lazy public var config: Config = combineConfigs()

    public var localConfig: Config? = nil

    public var localPartialConfig: PartialConfig? = nil
    
    public static var defaultConfig: Config {

        Config(stateConfigs: [:])
    }

    private let childBuilder: () -> Widget

    @Computed
    private var activeStateConfig: PartialConfigMarkerProtocol?

    @Computed
    private var providedConfigs: [PartialConfigMarkerProtocol]

    public init(@WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.childBuilder = childBuilder

        super.init()

        self._activeStateConfig.computeValue = { [unowned self] in

            config.stateConfigs[state]
        }

        self._activeStateConfig.dependencies = [self.$state.any]
   }

    override public func addedToParent() {
        
        self._providedConfigs.computeValue = { [unowned self] in

            return activeStateConfig != nil ? [activeStateConfig!] : []
        }

        self._providedConfigs.dependencies = [self.$activeStateConfig.any]
    }

    override public func buildChild() -> Widget {

        ConfigProvider($providedConfigs) { [unowned self] in

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

        case let event as GUIMouseButtonUpEvent:

            if globalBounds.contains(point: event.position) {

                self.state = .Hover

            } else {

                self.state = .Normal
            }

        default:

            return
        }
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