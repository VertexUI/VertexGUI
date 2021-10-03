import OpenCombine
import GfxMath

extension Widget {
	public func onSizeChanged(_ handler: @escaping (((newSize: DSize2, firstLayoutPass: Bool)) -> Void)) -> AnyCancellable{
		sizeChangedEventManager.sink(receiveValue: handler)
	}
}