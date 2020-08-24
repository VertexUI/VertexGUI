import Swim
import WidgetGUI
import VisualAppBase

public class InfoCard: SingleChildWidget, BoxWidget {
    private let image: Image
    private let title: String
    private let description: String

    public init(image: Image, title: String, description: String) {
        self.image = image
        self.title = title
        self.description = description
    }

    override public func buildChild() -> Widget {
        return Column(spacing: 32, items: [
            Column.Item { [unowned self] in 
                Text(title, fontSize: 48, fontWeight: .Bold)
            },
            Column.Item { [unowned self] in 
                Text(description)
            },
            Column.Item { [unowned self] in 
                ImageView(image: image)
            }
        ])
    }

    public func getBoxConfig() -> BoxConfig {
        return (child as! BoxWidget).getBoxConfig()
    }

    override public func performLayout() {
        if let child = child as? BoxWidget {
            child.constraints = constraints
            let config = child.getBoxConfig()
            child.bounds.size = config.preferredSize
            print("INFO CARD IS LAYOUTING", child)
            child.layout()
        }
    }
}