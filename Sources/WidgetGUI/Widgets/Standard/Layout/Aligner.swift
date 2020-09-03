import CustomGraphicsMath

public class Aligner: Widget {
    public init(@WidgetBuilder children childrenBuilder: () -> [Widget]) {
        super.init(children: childrenBuilder())
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
        var maxSize: DSize2 = .zero

        for child in children {

            child.layout(constraints: constraints)

            if child.bounds.size.width > maxSize.width {
                maxSize.width = child.bounds.size.width
            }
            if child.bounds.size.height > maxSize.height {
                maxSize.height = child.bounds.size.height
            }
        }

        let size = constraints.constrain(maxSize)

        for child in children {
            if let child = child as? Alignable {
                switch child.horizontalAlignment {
                case .Start:
                    child.bounds.min.x = 0
                case .Center:
                    child.bounds.min.x = size.width / 2 - child.bounds.size.width / 2
                case .End:
                    child.bounds.min.x = size.width - child.bounds.size.width
                }

                switch child.verticalAlignment {
                case .Start:
                    child.bounds.min.y = 0
                case .Center:
                    child.bounds.min.y = size.height / 2 - child.bounds.size.height / 2
                case .End:
                    child.bounds.min.y = size.height - child.bounds.size.height
                }
            }
        }

        return size
    }
}