import Foundation
import Swim
import WidgetGUI
import Path

let itemsListString = try! String(contentsOf: Bundle.module.path(forResource: "data", ofType: "json")!)

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
    private var infoItems: [InfoItem] = []

    public init() {
        let directoryNames = try! JSONSerialization.jsonObject(with: itemsListString.data(using: .utf8)!)
        
        for directoryName in directoryNames as! [Any] {

            if let directoryName = directoryName as? String {

                infoItems.append(InfoItem(from: Path(Bundle.module.resourcePath!)!/directoryName))
            }
        }
    }

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
                Column(items: infoItems.map { infoItem in
                    Column.Item {
                        InfoCard(infoItem: infoItem)
                    }
                })
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