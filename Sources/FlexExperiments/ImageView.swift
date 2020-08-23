import WidgetGUI
import VisualAppBase
import CustomGraphicsMath
import Swim

public class ImageView: Widget, BoxWidget {
    public var image: Image<RGBA, UInt8>
    
    public init(image: Image<RGBA, UInt8>) {
       self.image = image
    }

    public func getBoxConfig() -> BoxConfig {
        BoxConfig(preferredSize: DSize2(Double(image.width), Double(image.height)))
    }

    override public func renderContent() -> RenderObject? {
        if bounds.size.width <= 0 || bounds.size.height <= 0 {
            return nil
        }

        let resizedImage = image.resize(width: Int(bounds.size.width), height: Int(bounds.size.height))

        return RenderObject.RenderStyle(fill: FixedRenderValue(.Image(resizedImage, position: globalBounds.min))) {
            RenderObject.Rectangle(globalBounds)
        }
    }

    override public func performLayout() {
        
    }
}