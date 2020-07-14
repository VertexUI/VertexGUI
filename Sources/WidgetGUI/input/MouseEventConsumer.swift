//

//

import Foundation

public protocol MouseEventConsumer: Bounded {
    func consume(_ event: GUIMouseEvent) throws
}