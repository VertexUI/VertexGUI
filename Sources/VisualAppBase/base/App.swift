import Dispatch
import Foundation

open class App<S: System, W: Window> {
    public typealias System = S
    public typealias Window = W

    public var system: System

    public init(system: System) {
        self.system = system
    }

    /*
    /// Setup the system and other app specific things. Should be called by start().
    open func setup() throws {
        fatalError("setup not implemented.")
    }*/

    open func exit() {
        
        system.exit()
    }

    /// Call setup() and other things necessary to run in the correct DispatchQueue.
    /// Will block until exit is executed.
    open func start() throws {
        #if os(macOS)
        try self.system.mainLoop() // { $0() }
        RunLoop.main.run()
        #elseif os(Linux)
        try self.system.mainLoop() // { (_ block: @escaping () -> ()) in
        dispatchMain()
        #else
        fatalError("Unsupported os.")
        #endif
    }
}