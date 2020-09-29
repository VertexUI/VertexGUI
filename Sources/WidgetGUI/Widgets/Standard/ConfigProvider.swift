public class ConfigProvider: SingleChildWidget {

    private var configs: [PartialConfigMarkerProtocolProtocol]

    private var childBuilder: () -> Widget
    
    public init(_ configs: [PartialConfigMarkerProtocolProtocol], @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.configs = configs

        self.childBuilder = childBuilder
    }

    public convenience init(_ configs: PartialConfigMarkerProtocolProtocol..., @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.init(configs, child: childBuilder)
    }

    override public func buildChild() -> Widget {

        childBuilder()
    }

    public func retrieveConfig<Config: PartialConfigProtocol>(ofType configType: Config.Type) -> Config? {

        for config in configs {

            if let config = config as? Config {

                return config
            }
        }

        return nil
    }
}