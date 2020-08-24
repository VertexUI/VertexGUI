import Swim
import WidgetGUI

public class InfoCard: SingleChildWidget, BoxWidget {
    private let image: Image
    private let text: String

    public init(image: Image, text: String) {
        self.image = image
        self.text = text
    }

    override public func buildChild() -> Widget {
        Column(items: [
            Column.Item {
                Text("WOW THE COLUMN WORKS!")
            }
        ])
    }

    public func getBoxConfig() -> BoxConfig {
        return (child as! BoxWidget).getBoxConfig()
    }
}