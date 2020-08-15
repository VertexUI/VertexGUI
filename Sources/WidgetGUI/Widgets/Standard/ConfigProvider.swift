public class ConfigProvider: SingleChildWidget {
    private var configs: [PartialConfigMarker]
    private var childBuilder: () -> Widget
    
    public init(configs: [PartialConfigMarker], @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        self.configs = configs
        self.childBuilder = childBuilder
    }

    public convenience init(configs: PartialConfigMarker..., @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        self.init(configs: configs, child: childBuilder)
    }

    override public func buildChild() -> Widget {
        childBuilder()
    }

    public func retrieveConfig<Config: PartialConfig>(ofType configType: Config.Type) -> Config? {
        for config in configs {
            if let config = config as? Config {
                return config
            }
        }
        return nil
    }
}