import WidgetGUI
import VisualAppBase
import CustomGraphicsMath
import Swim

public class ImageView: Widget {
    public var image: Image<RGBA, UInt8>
    
    public init(image: Image<RGBA, UInt8>) {
       self.image = image
       print("GOT IMAGE", image)
    }

    override public func renderContent() -> RenderObject? {
        let targetSize = DSize2(400, 900)

        let resizedImage = image.resize(width: Int(targetSize.width), height: Int(targetSize.height))

        return RenderObject.RenderStyle(fill: FixedRenderValue(.Image(resizedImage))) {
            RenderObject.Rectangle(DRect(min: .zero, size: targetSize))
        }
    }
}