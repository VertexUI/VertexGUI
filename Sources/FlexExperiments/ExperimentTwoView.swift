import Foundation
import Swim
import WidgetGUI

public class ExperimentTwoView: SingleChildWidget {
    override public func buildChild() -> Widget {
        return Row(spacing: 16, wrap: true, items: [
            Row.Item {
                Text("Text One that brings other things to overflow Text One that brings other things to overflow Text One that brings other things to overflow")
            },
            Row.Item {
                Row(spacing: 80, items: [
                    Row.Item { 
                        Text("Row in Row Text 1")
                    },
                    Row.Item {
                        Text("Row in Row Text 2")
                    }
                ])
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