import GfxMath

public struct GamePerspective {
    public let visibleArea: DRect
    public var center: DPoint2 {
        DPoint2(visibleArea.min + (visibleArea.max - visibleArea.min) / 2)
    }

    public init(visibleArea: DRect) {
        self.visibleArea = visibleArea
    }
}