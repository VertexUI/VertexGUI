//

//

import Foundation

// TODO: maybe don't need this, or make it return renderObjects!!
open class Renderable<S: System, W: Window, R: Renderer>: Contextualized<S, W, R> {
    open func render(renderer: R) throws {
        fatalError("Render function not implemented.")
    }
}