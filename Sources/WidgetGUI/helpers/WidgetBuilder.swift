@_functionBuilder
public struct WidgetBuilder {
    public static func buildBlock<W: Widget>(_ widget: W) -> W {
        return widget
    }

    //public static func buildBlock<W1: Widget, W2: Widget>(_ widget1: W1, _ widget2: W2) -> 

    public static func buildBlock<W1: Widget, W2: Widget>(_ w1: W1, _ w2: W2) -> (W1, W2) {
        return (w1, w2)
    }
}