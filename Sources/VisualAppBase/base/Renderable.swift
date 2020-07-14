//
// Created by adrian on 14.04.20.
//

import Foundation

open class Renderable<S: System<W, R>, W: Window, R: Renderer>: Contextualized<S, W, R> {
    open func render(renderer: R) throws {
        fatalError("Render function not implemented.")
    }
}