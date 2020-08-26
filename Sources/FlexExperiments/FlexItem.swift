import WidgetGUI

public struct FlexItem {
    var grow: Int
    var crossAlignment: FlexAlignment
    var content: Widget

    public init(grow: Int = 0, crossAlignment: FlexAlignment = .Start, @WidgetBuilder content contentBuilder: @escaping () -> Widget) {
        self.grow = grow
        self.crossAlignment = crossAlignment
        self.content = contentBuilder()
    }

    public func getBoxConfig() -> BoxConfig {
        BoxConfig(preferredSize: .zero)
    }
}