public protocol ConfigurableWidget where Self: Widget, Config.PartialConfig == PartialConfig {
    associatedtype Config: ConfigProtocol
    associatedtype PartialConfig: PartialConfigProtocol
  
    static var defaultConfig: Config { get }
    var localConfig: Config? { get set }
    var localPartialConfig: PartialConfig? { get set }
    var config: Config { get }

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

    func combineConfigsComputed() -> ComputedProperty<Config> {
        // TODO: maybe provide an extra flag through Widget to see whether Widget was added to a parent
        if parent == nil {
            fatalError("Tried to call combineConfigs() before Widget was added to parent.")
        }

        if let fullConfig = localConfig {
            return ComputedProperty([]) { fullConfig }
        }

        let computedInheritedPartial = getConfig(ofType: PartialConfig.self)

        // TODO: if a config provider parent changes the Computed property has to be setup again!
        
        // store this variable here to avoid having to specify "unowned self" for the
        // following closure as this crashes the swift compiler (5.3)
        let localPartialConfig = self.localPartialConfig

        return ComputedProperty([computedInheritedPartial.any]) {
            let inheritedPartial = computedInheritedPartial.value
            let combinedPartial = PartialConfig.merged(partials: [localPartialConfig, inheritedPartial].compactMap { $0 })
            return Self.defaultConfig.merged(with: combinedPartial)
        }
    }

    func combineConfigs() -> Config {
        combineConfigsComputed().value
    }
}
