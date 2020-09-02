import CustomGraphicsMath
import WidgetGUI

// TODO: maybe simply provide these as modifiers on each Widget?
public class ConstrainedSize: SingleChildWidget {

    private var minSize: DSize2?

    private var maxSize: DSize2?
    
    private var childBuilder: () -> Widget

    public init(minSize: DSize2? = nil, maxSize: DSize2? = nil, @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.minSize = minSize

        self.maxSize = maxSize

        self.childBuilder = childBuilder
    }

    override public func buildChild() -> Widget {

        childBuilder()
    }

    override public func getBoxConfig() -> BoxConfig {

        let childConfig = child.boxConfig
        
        var config = BoxConfig(

            preferredSize: childConfig.preferredSize,

            minSize: minSize ?? childConfig.minSize,

            maxSize: maxSize ?? childConfig.maxSize
        )

        config.preferredSize = BoxConstraints(minSize: config.minSize, maxSize: config.maxSize).constrain(childConfig.preferredSize)

        return config
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        child.layout(constraints: BoxConstraints(

            minSize: constraints.constrain(minSize ?? constraints.minSize),
            
            maxSize: constraints.constrain(maxSize ?? constraints.maxSize)))

        return constraints.constrain(child.bounds.size)
    }
}