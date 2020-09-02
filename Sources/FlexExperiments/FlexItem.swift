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

    var margins: Margins

    public init(

        grow: Double = 0,

        crossAlignment: FlexAlignment = .Start,

        width: FlexValue? = nil,

        height: FlexValue? = nil,

        margins: Margins = Margins(all: 0),

        @WidgetBuilder content contentBuilder: @escaping () -> Widget) {

            self.grow = grow

            self.crossAlignment = crossAlignment

            self.width = width

            self.height = height

            self.margins = margins

            self.content = contentBuilder()
    }
}