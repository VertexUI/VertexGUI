import VisualAppBase
import CustomGraphicsMath
import Foundation
import Dispatch
import ColorizeSwift

public class ImageView: Widget {

    private var image: Image

    private var resizedImage: Image?

    private var resizingImage = false

    private let onImageResized = EventHandlerManager<Void>()
    
    public init(image: Image) {

        self.image = image

        super.init()

        _ = onDestroy(onBoundsChanged { [unowned self] _ in

            print("IMAGE BOUNDS CHANGED!".onWhite(), bounds.size)

            if resizingImage {

                onImageResized.once {

                    resizedImage = nil

                    invalidateRenderState()
                }

            } else {
            
                resizedImage = nil

                invalidateRenderState()
            }
       })
    }

    override public func getBoxConfig() -> BoxConfig {

        BoxConfig(preferredSize: DSize2(Double(image.width), Double(image.height)))
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
        
        var width = max(constraints.minWidth, min(constraints.maxWidth, boxConfig.preferredSize.width))

        var scale = width / boxConfig.preferredSize.width

        var height = boxConfig.preferredSize.height * scale

        if height < constraints.minHeight || height > constraints.maxHeight {

            height = max(constraints.minHeight, min(constraints.maxWidth, boxConfig.preferredSize.height))

            scale = height / boxConfig.preferredSize.height

            width = boxConfig.preferredSize.width * scale
        }

        return constraints.constrain(DSize2(width, height))
    }

    override public func renderContent() -> RenderObject? {

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
    }

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