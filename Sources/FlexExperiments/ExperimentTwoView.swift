import Foundation
import Swim
import WidgetGUI

public class ExperimentTwoView: SingleChildWidget {
    override public func buildChild() -> Widget {
        return Row(items: [
            Row.Item {
                Text("TestText")
            },
            Row.Item {
                ImageView(image: try! Image(contentsOf: Bundle.module.url(forResource: "owl", withExtension: "jpg")!))
            }
        ])
    }
}