//

//

import Foundation
/*

UNUSED

public protocol MouseEventProvider {
    var mouseEventConsumers: [MouseEventConsumer] { get set }

    mutating func addMouseEventConsumer(_ consumer: MouseEventConsumer)
    func provideMouseEvent(_ event: GUIMouseEvent) throws
}

public extension MouseEventProvider {
    mutating func addMouseEventConsumer(_ consumer: MouseEventConsumer) {
        mouseEventConsumers.append(consumer)
    }

    func provideMouseEvent(_ event: GUIMouseEvent) throws {

        for consumer in mouseEventConsumers {
            if (consumer.globalBounds.contains(point: event.position)) {
                try consumer.consume(event)
                if (event is GUIMouseMoveEvent) {
                    let moveEvent = event as! GUIMouseMoveEvent
                    if (!consumer.globalBounds.contains(point: moveEvent.previousPosition)) {
                        try consumer.consume(GUIMouseEnterEvent(position: event.position, previousPosition: moveEvent.previousPosition))
                    }
                }
            } else {
                if (event is GUIMouseMoveEvent) {
                    let moveEvent = event as! GUIMouseMoveEvent
                    if (consumer.globalBounds.contains(point: moveEvent.previousPosition)) {
                        try consumer.consume(GUIMouseLeaveEvent(position: event.position, previousPosition: moveEvent.previousPosition))
                    }
                } else if (event is GUIMouseLeaveEvent) {
                    if (consumer.globalBounds.contains(point: (event as! GUIMouseLeaveEvent).previousPosition)) {
                        try consumer.consume(event)
                    }
                }
            }
        }
    }
}*/