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
        Column(items: [
            Column.Item { [unowned self] in 
                Text(title, fontSize: 24, fontWeight: .Bold)
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
}