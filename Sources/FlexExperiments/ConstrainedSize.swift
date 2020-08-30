import CustomGraphicsMath
import WidgetGUI

// TODO: maybe simply provide these as modifiers on each Widget?
public class ConstrainedSize: SingleChildWidget {

    private var minSize: DSize2?

    private var maxSize: DSize2?
    
    private var preferredSize: DSize2?

    private var childBuilder: () -> Widget

    public init(preferredSize: DSize2? = nil, minSize: DSize2? = nil, maxSize: DSize2? = nil, @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.preferredSize = preferredSize
        
        self.minSize = minSize

        self.maxSize = maxSize

        self.childBuilder = childBuilder
    }

    public convenience init(size: DSize2, @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.init(preferredSize: size, minSize: size, maxSize: size, child: childBuilder)
    }

    override public func buildChild() -> Widget {

        childBuilder()
    }

    override public func getBoxConfig() -> BoxConfig {

        let childConfig = child.boxConfig
        
        var config = BoxConfig(

            preferredSize: preferredSize ?? childConfig.preferredSize,

            minSize: minSize ?? childConfig.minSize,

            maxSize: maxSize ?? childConfig.maxSize
        )

        if config.maxSize.width < config.preferredSize.width {

            config.preferredSize.width = config.maxSize.width
        }

        if config.maxSize.height < config.preferredSize.height {

            config.preferredSize.height = config.maxSize.height
        }

        return config
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        if let explicitPreferredSize = preferredSize {

            child.layout(constraints: BoxConstraints(
                
                minSize: constraints.constrain(boxConfig.minSize),

                maxSize: constraints.constrain(explicitPreferredSize)))

        } else {

            child.layout(constraints: BoxConstraints(

                minSize: constraints.constrain(boxConfig.minSize),
                
                maxSize: constraints.constrain(boxConfig.maxSize)))
        }

        return child.bounds.size
    }
}