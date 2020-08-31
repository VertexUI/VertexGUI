import WidgetGUI

public struct FlexItem {

    public enum FlexValue {

        case Pixels(_ value: Double)

        case Percent(_ value: Double)
    }

    var grow: Double

    var crossAlignment: FlexAlignment

    var content: Widget

    var width: FlexValue?

    var height: FlexValue?

    public init(

        grow: Double = 0,

        crossAlignment: FlexAlignment = .Start,

        width: FlexValue? = nil,

        height: FlexValue? = nil,

        @WidgetBuilder content contentBuilder: @escaping () -> Widget) {

            self.grow = grow

            self.crossAlignment = crossAlignment

            self.width = width

            self.height = height

            self.content = contentBuilder()
    }
}