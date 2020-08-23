import WidgetGUI

public protocol BoxWidget: Widget {
    func getBoxConfig() -> BoxConfig
}