import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

public class ImageView: Widget, BoxWidget {
    private var image: Image

    private var resizedImage: Image?
    //private var imageHash: Int?
    
    public init(image: Image) {
       self.image = image
    }

    public func getBoxConfig() -> BoxConfig {
        BoxConfig(preferredSize: DSize2(Double(image.width), Double(image.height)))
    }

    override public func renderContent() -> RenderObject? {
        if bounds.size.width <= 0 || bounds.size.height <= 0 {
            return nil
        }

        if resizedImage == nil || resizedImage!.width != Int(bounds.size.width) || resizedImage!.height != Int(bounds.size.height) {
            resizedImage = image.resize(width: Int(bounds.size.width), height: Int(bounds.size.height))
            //imageHash = resizedImage.hashValue
        }

        return RenderObject.RenderStyle(fill: FixedRenderValue(.Image(resizedImage!/*, hash: imageHash!*/, position: globalBounds.min))) {
            RenderObject.Rectangle(globalBounds)
        }
    }

    override public func performLayout() {
        
    }
}