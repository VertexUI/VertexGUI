import CustomGraphicsMath
import WidgetGUI

public class ConstrainedSize: SingleChildWidget {
    private var minSize: DSize2?
    private var maxSize: DSize2?
    private var preferredSize: DSize2?
    private var aspectRatio: Double?

    private var childBuilder: () -> Widget

    public init(preferredSize: DSize2? = nil, minSize: DSize2? = nil, maxSize: DSize2? = nil, aspectRatio: Double? = nil, @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        self.preferredSize = preferredSize
        self.minSize = minSize
        self.maxSize = maxSize
        self.aspectRatio = aspectRatio

        self.childBuilder = childBuilder
    }

    override public func buildChild() -> Widget {
        childBuilder()
    }

    override public func getBoxConfig() -> BoxConfig {
        let childConfig = child.boxConfig
        
        var config = BoxConfig(
            preferredSize: preferredSize ?? childConfig.preferredSize,
            minSize: minSize ?? childConfig.minSize,
            maxSize: maxSize ?? childConfig.maxSize,
            aspectRatio: aspectRatio ?? childConfig.aspectRatio
        )

        if config.maxSize.width < config.preferredSize.width {
            config.preferredSize.width = config.maxSize.width
        }
        if config.maxSize.height < config.preferredSize.height {
            config.preferredSize.height = config.maxSize.height
        }

        return config
    }

    override public func performLayout() {
        child.constraints = constraints // legacy

        child.bounds.size = bounds.size

        child.layout()
    }
}