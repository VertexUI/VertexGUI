//
// Created by adrian on 18.04.20.
//

import Foundation

public protocol MouseEventConsumer: Bounded {
    func consume(_ event: GUIMouseEvent) throws
}