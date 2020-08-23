import Foundation
import Swim
import WidgetGUI

public class ExperimentTwoView: SingleChildWidget {
    override public func buildChild() -> Widget {
        return Row(items: [
            Row.Item {
                Text("Testsasdasdasdasdasdext")
            },
            Row.Item {
                ImageView(
                    image: try! Image(
                        contentsOf: Bundle.module.url(
                            forResource: "owl", withExtension: "jpg")!))
            }
        ])
    }

    override public func performLayout() {
        child.constraints = constraints
        child.bounds.size = constraints!.maxSize
        bounds.size = constraints!.maxSize
        child.layout()
    }
}