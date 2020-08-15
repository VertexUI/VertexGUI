public protocol ConfigurableWidget: class where Self: Widget, Config.PartialConfig == PartialConfig {
    associatedtype Config: WidgetGUI.Config
    associatedtype PartialConfig: WidgetGUI.PartialConfig

    static var defaultConfig: Config { get }
    var localConfig: Config? { get set }
    var localPartialConfig: PartialConfig? { get set }
    var config: Config { get set }

    func with(config: Config) -> Self
    func with(config: PartialConfig) -> Self
    func combineConfigs() -> Config
}

public extension ConfigurableWidget {
    @discardableResult func with(config: Config) -> Self {
        self.localConfig = config
        return self
    }

    @discardableResult func with(config: PartialConfig) -> Self {
        self.localPartialConfig = config
        return self
    }

    func combineConfigs() -> Config {
        // TODO: maybe provide an extra flag through Widget to see whether Widget was added to a parent
        if parent == nil {
            fatalError("Tried to call combineConfigs() before Widget was added to parent.")
        }

        if let fullConfig = localConfig {
            return fullConfig
        }

        let inheritedPartial = getConfig(ofType: PartialConfig.self)

        let combinedPartial = PartialConfig(partials: [localPartialConfig, inheritedPartial].compactMap { $0 })

        return Config(partial: combinedPartial, default: Self.defaultConfig)
    }
}