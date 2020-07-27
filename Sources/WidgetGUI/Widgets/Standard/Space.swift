import CustomGraphicsMath
import VisualAppBase

public class Space: LeafWidget {
    public var size: DSize2 {
        didSet {
            try! layout()
        }
    }

    public init(size: DSize2) {
        self.size = size
        super.init()
    }

    override public func layout() throws {
        bounds.size = size
    }

    override public func render() -> RenderObject? {
        return nil
    }
}