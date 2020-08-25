import Foundation
import Swim
import WidgetGUI

public class ExperimentTwoView: SingleChildWidget {
    private var owlImages = [
        try! Image(
            contentsOf: Bundle.module.url(
                forResource: "owl", withExtension: "jpg")!),
        try! Image(
            contentsOf: Bundle.module.url(
                forResource: "owl-2", withExtension: "jpg")!),
        try! Image(
            contentsOf: Bundle.module.url(
                forResource: "owl-3", withExtension: "jpg")!)
    ]

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
            },
            Row.Item { [unowned self] in
                InfoCard(
                    images: owlImages,
                    title: "The owl!",
                    description: "The owl is an animal that can fly because it has wings. It mainly flies during the night because it doesn't fly during the day."
                )
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