import Swim
import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

public class InfoCard: SingleChildWidget, BoxWidget {
    private let images: [Image]
    private let title: String
    private let description: String

    public init(images: [Image], title: String, description: String) {
        self.images = images
        self.title = title
        self.description = description
    }

    override public func buildChild() -> Widget {
        var imagesMinHeight = Double.infinity
        for image in images {
            if Double(image.height) < imagesMinHeight {
                imagesMinHeight = Double(image.height)
            }
        }
        let imagesMaxSize = DSize2(.infinity, imagesMinHeight)

        return Column(spacing: 32, items: [

            Column.Item { [unowned self] in 
                Text(title, fontSize: 48, fontWeight: .Bold)
            },

            Column.Item { [unowned self] in 
                Text(description)
            },

            Column.Item { [unowned self] in 

                ConstrainedSize(maxSize: imagesMaxSize) {

                    Row(items: images.map { image in 

                        Row.Item { ImageView(image: image) }
                    })
                }
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