import VisualAppBase
import GfxMath
import Foundation
import Dispatch
import ColorizeSwift
import Events

public class ImageView: Widget {
    private var image: Image
    private var resizedImage: Image?
    private var resizingImage = false
    private let onImageResized = EventHandlerManager<Void>()
    
    public init(image: Image) {
        self.image = image
        super.init()

        _ = onDestroy(onSizeChanged { [unowned self] _ in
            if resizingImage {
                _ = onImageResized.once {
                    resizedImage = nil
                }
            } else {
                resizedImage = nil
            }
       })
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
        var width = max(constraints.minWidth, min(constraints.maxWidth, Double(image.width)))
        var scale = width / Double(image.width)
        var height = Double(image.height) * scale

        if height < constraints.minHeight || height > constraints.maxHeight {
            height = max(constraints.minHeight, min(constraints.maxWidth, Double(image.width)))
            scale = height / Double(image.height)
            width = Double(image.width) * scale
        }

        return constraints.constrain(DSize2(width, height))
    }

    /*override public func renderContent() -> RenderObject? {
        if bounds.size.width <= 0 || bounds.size.height <= 0 {
            return nil
        }

        if !resizingImage && (resizedImage == nil || resizedImage!.width != Int(bounds.size.width) || resizedImage!.height != Int(bounds.size.height)) {
            resizeImage()
            return nil
        } else if resizedImage != nil {
            return RenderObject.RenderStyle(fill: FixedRenderValue(.Image(resizedImage!, position: globalBounds.min))) {
                RenderObject.Rectangle(globalBounds)
            }
        } else {
            return nil
        }
    }*/

    private func resizeImage() {
        resizingImage = true
        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            let resizedImage = image.resize(width: Int(bounds.size.width), height: Int(bounds.size.height))
            DispatchQueue.main.async {
                self.resizedImage = resizedImage
                resizingImage = false
                onImageResized.invokeHandlers(Void())
                invalidateRenderState()
            }
        }
    }
}
