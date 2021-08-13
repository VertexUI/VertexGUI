import SkiaKit
import GfxMath

extension Path {
	public func move(to point: FVec2) {
		moveTo(point.x, point.y)
	}

	public func line(to point: FVec2) {
		lineTo(point.x, point.y)
	}
}