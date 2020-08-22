import WidgetGUI

public class ExperimentTwoView: SingleChildWidget {
    override public func buildChild() -> Widget {
        Row(items: [
            Row.Item {
                Text("TestText")
            }
        ])
    }
}