import SkiaKit
import Swim

extension SkiaKit.Image {
  public convenience init?(_ swimImage: Swim.Image<RGBA, UInt8>) {
    let skiaImageInfo = ImageInfo(
      width: Int32(swimImage.width),
      height: Int32(swimImage.height),
      colorType: .rgba8888,
      alphaType: .unpremul)

    let imageData = swimImage.getData()
    let drawableImageDataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: imageData.count)
    drawableImageDataPointer.initialize(from: imageData, count: imageData.count)

    let skiaPixmap = Pixmap(info: skiaImageInfo, addr: UnsafeMutableRawPointer(drawableImageDataPointer))
    self.init(pixmap: skiaPixmap, releaseProc: { addr, _ in
      addr?.deallocate()
    })
  }
}