import VisualAppBase

public class ConfigProvider: SingleChildWidget {

    @Observable public internal(set) var configs: [PartialConfigMarkerProtocol]

    private var childBuilder: () -> Widget

   // public internal(set) var onConfigsChanged = EventHandlerManager<Void>()

    public init(_ configs: Observable<[PartialConfigMarkerProtocol]>, @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.childBuilder = childBuilder

        self._configs = configs

        super.init()

       /* _ = onDestroy(self._configs.onChanged { [unowned self] _ in

            onConfigsChanged.invokeHandlers(Void())
        })*/
    }

    public convenience init(_ configs: [PartialConfigMarkerProtocol], @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.init(ObservableArray(configs), child: childBuilder)
    }

    public convenience init(_ configs: PartialConfigMarkerProtocol..., @WidgetBuilder child childBuilder: @escaping () -> Widget) {

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

   /* override public func destroySelf() {

        onConfigsChanged.removeAllHandlers()
    }*/
}