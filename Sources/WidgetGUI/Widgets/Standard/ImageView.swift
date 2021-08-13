import Foundation
import GfxMath
import SkiaKit
import Events
import Drawing
import Swim

public class ImageView: LeafWidget {
    @ImmutableBinding
    private var image: Swim.Image<RGBA, UInt8>
    private var drawableImage: SkiaKit.Image?
    private var drawableImageDataPointer: UnsafeMutablePointer<UInt8>?

    private var imageSubscription: Any?
    
    public init(image imageBinding: ImmutableBinding<Swim.Image<RGBA, UInt8>>) {
        self._image = imageBinding
        super.init()

        updateDrawableImage()
        
        var oldImageSize = (image.width, image.height)
        self.imageSubscription = $image.publisher.sink { [unowned self] newImage in
            updateDrawableImage()

            let newImageSize = (newImage.width, newImage.height)

            if oldImageSize != newImageSize {
                oldImageSize = newImageSize
                invalidateLayout()
            }
        }
    }

    public init(image: Swim.Image<RGBA, UInt8>) {
        self._image = ImmutableBinding(get: { image })
        super.init()

        updateDrawableImage()
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

    override public func draw(_ drawingContext: DrawingContext, canvas: Canvas) {
        if let drawableImage = drawableImage {
            canvas.drawImage(drawableImage, 0, 0)
        }
    }

    private func updateDrawableImage() {
        drawableImageDataPointer?.deallocate()

        let skiaImageInfo = ImageInfo(
          width: Int32(image.width),
          height: Int32(image.height),
          colorType: .rgba8888,
          alphaType: .unpremul)

        var imageData = image.getData()
        drawableImageDataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: imageData.count)
        drawableImageDataPointer!.initialize(from: imageData, count: imageData.count)

        let skiaPixmap = Pixmap(info: skiaImageInfo, addr: UnsafeMutableRawPointer(drawableImageDataPointer!))
        drawableImage = SkiaKit.Image(pixmap: skiaPixmap)!
    }

    deinit {
        drawableImageDataPointer?.deallocate()
    }
}
