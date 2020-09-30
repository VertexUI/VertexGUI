import VisualAppBase
import CustomGraphicsMath

public class ThemeProvider: ConfigProvider {
    public init(_ theme: Theme, @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        super.init(ObservableArray(theme.configs), child: childBuilder)
    }
}