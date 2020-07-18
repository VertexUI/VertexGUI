import VisualAppBase

/// Renders a tree of widgets to a tree of render objects.
public class WidgetRenderTreeGenerator {
    public func generate(_ widget: Widget?) -> IdentifiedSubTreeRenderObject {
        switch widget {
        case let widget as LeafWidget:
            return IdentifiedSubTreeRenderObject(widget.id, [widget.render()].compactMap { $0 })
        case let widget as SingleChildWidget:
            return IdentifiedSubTreeRenderObject(widget.id, [widget.render(generate(widget.child))].compactMap { $0 })
        case let widget as MultiChildWidget:
            return IdentifiedSubTreeRenderObject(widget.id, [widget.render(widget.children.map(generate))].compactMap { $0 })
        default:
            fatalError("Unsupported widget type.")
        }        
    }
}