import VisualAppBase
import CustomGraphicsMath

public extension Root {

    internal func propagate(_ event: RawMouseEvent) {

        print("PROPAGATE NEW MOUSE EVENT", event)

        let renderObjectsAtPoint = self.renderObjectTree.objectsAt(point: event.position)

        for renderObjectAtPoint in renderObjectsAtPoint {

            if let object = renderObjectAtPoint.object as? IdentifiedSubTreeRenderObject {

                print("Mouse Event On Identified RenderObject with id", object.id)
     
                if let widget = rootWidget.getChild { $0.id == object.id } {

                    print("WOW got a widget", widget)
                    if let widget = widget as? GUIMouseEventConsumer {

                        print("WOW GOT A MOUSE CONSUMER WIDGET!!!!")
                        switch event {
                        
                        case let event as RawMouseButtonDownEvent:

                            widget.consume(GUIMouseButtonDownEvent(button: event.button, position: renderObjectAtPoint.transformedPoint))

                        case let event as RawMouseButtonUpEvent:

                            widget.consume(GUIMouseButtonUpEvent(button: event.button, position: renderObjectAtPoint.transformedPoint))

                        case let event as RawMouseMoveEvent:

                            let pointTransformation = renderObjectAtPoint.transformedPoint - event.position

                            widget.consume(GUIMouseMoveEvent(position: renderObjectAtPoint.transformedPoint, previousPosition: event.previousPosition + pointTransformation))

                        default:

                            print("Unsupported event.")
                        }
                     
                        // TODO: implement click

                        //widget.consume(GUIMouseButtonClickEvent(button: .Left, position: renderObjectAtPoint.transformedPoint))
                    }
                }
            }
        }
    }
}