public struct WidgetSelector: Hashable {
    // TODO: make initializable from string literal
    public let type: ObjectIdentifier
    public let classes: [String]

    public init<T: Widget>(type: T.Type, classes: String...) {
        self.type = ObjectIdentifier(type)
        self.classes = classes
    }

    public func selects<W: Widget>(_ widget: W) -> Bool {
        if widget.classes.count != classes.count || ObjectIdentifier(W.self) != type {
            return false
        }

        let selectorClasses = classes.sorted()
        let widgetClasses = widget.classes.sorted()
        return selectorClasses == widgetClasses
    }
}