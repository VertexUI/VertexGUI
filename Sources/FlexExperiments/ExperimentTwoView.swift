import Foundation
import Swim
import WidgetGUI
import Path

let itemsListString = try! String(contentsOf: Bundle.module.path(forResource: "data", ofType: "json")!)

public class ExperimentTwoView: SingleChildWidget {
    private var infoItems: [InfoItem] = []

    private var activeInfoItem: InfoItem?

    public init() {
        let directoryNames = try! JSONSerialization.jsonObject(with: itemsListString.data(using: .utf8)!)
        
        for directoryName in directoryNames as! [Any] {

            if let directoryName = directoryName as? String {

                infoItems.append(InfoItem(from: Path(Bundle.module.resourcePath!)!/directoryName))
            }
        }
    }

    override public func buildChild() -> Widget {
        return Row(spacing: 1, wrap: true, items: [

            Row.Item(crossAlignment: .Stretch) { [unowned self] in

                Background(color: .White) {

                    Padding(top: 32, right: 48, bottom: 32, left: 32) {

                        Column(spacing: 24, items: [
                            Column.Item {
                                Text("Items", fontSize: 28, fontWeight: .Bold)
                            }
                        ] + infoItems.map { infoItem in

                            Column.Item {
                                MouseArea {
                                    Text(infoItem.title)
                                } onClick: { _ in
                                    print("clICKED INFO ITEM")
                                }
                            }

                        })
                    }
                }
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