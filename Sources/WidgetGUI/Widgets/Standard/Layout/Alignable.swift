import GfxMath

public class Alignable: Widget {
    public enum Alignment {
        case Start, Center, End
    }

    // TODO: needed or just wrap in padding??
    /*public struct Margins {
        public var top: Double
        public var right: Double
        public var bottom: Double
        public var left: Double

        public init(top: Double = 0, right: Double = 0, bottom: Double = 0, left: Double = 0) {
            self.top = top
            self.right = right
            self.bottom = bottom
            self.left = left
        }
    }*/

    public internal(set) var horizontalAlignment: Alignment 
    public internal(set) var verticalAlignment: Alignment
    //public internal(set) var margins: Margins

    private var child: Widget {
        children[0]
    }

    public init(
        horizontal horizontalAlignment: Alignment = .Start,
        vertical verticalAlignment: Alignment = .Start,
        //margins: Margins = Margins(),
        @WidgetBuilder child childBuilder: () -> Widget) {
            self.horizontalAlignment = horizontalAlignment
            self.verticalAlignment = verticalAlignment
            //self.margins = margins
            super.init(children: [ childBuilder() ])
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        child.layout(constraints: constraints)
        
        return constraints.constrain(child.bounds.size)
    }
}