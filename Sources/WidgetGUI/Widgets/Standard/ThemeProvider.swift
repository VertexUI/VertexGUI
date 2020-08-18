import VisualAppBase
import CustomGraphicsMath

public class ThemeProvider: ConfigProvider {
    public init(_ theme: Theme, @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        super.init(configs: theme.configs, child: childBuilder)
    }
}