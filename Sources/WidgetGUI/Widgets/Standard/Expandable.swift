import VisualAppBase

// TODO: finish Expandable
public class Expandable: SingleChildWidget, StatefulWidget {
    public typealias State = Bool

    public var state: State = false {
        didSet {
            invalidateChild()
        }
    }

    private var expanded: Bool {
        get {
            state
        }

        set {
            state = newValue
        }
    }

    private var childBuilder: () -> Widget
    
    public init(@WidgetBuilder child childBuilder: @escaping () -> Widget) {
        self.childBuilder = childBuilder
        super.init()
    }

    override public func buildChild() -> Widget {
        Column { [unowned self] in
            MouseArea {
                Text("Head")
            } onClick: { _ in
                expanded = !expanded
            }

            if expanded {
                childBuilder()
            }
        }
    }
}