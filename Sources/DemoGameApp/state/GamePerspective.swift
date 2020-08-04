import CustomGraphicsMath

public struct GamePerspective {
    public let visibleArea: DRect
    /*public var center: DPoint2 {

    }*/

    public init(visibleArea: DRect) {
        self.visibleArea = visibleArea
    }
}