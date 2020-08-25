import Swim
import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

public class InfoCard: SingleChildWidget, BoxWidget {
    private let infoItem: InfoItem

    public init(infoItem: InfoItem) {
        self.infoItem = infoItem
    }

    override public func buildChild() -> Widget {
        var imagesMinHeight = Double.infinity
        for image in infoItem.images {
            if Double(image.height) < imagesMinHeight {
                imagesMinHeight = Double(image.height)
            }
        }
        let imagesMaxSize = DSize2(.infinity, imagesMinHeight)

        return Background(color: .White) {
            Padding(all: 32) {
                Column(spacing: 32, items: [
                    Column.Item { [unowned self] in 
                        Text(infoItem.title, fontSize: 48, fontWeight: .Bold)
                    },

                    Column.Item { [unowned self] in 
                        Text(infoItem.description)
                    },

                    Column.Item { [unowned self] in 

                        ConstrainedSize(maxSize: imagesMaxSize) {

                            Row(items: infoItem.images.map { image in 

                                Row.Item { ImageView(image: image) }
                            })
                        }
                    }
                ])
            }
        }
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