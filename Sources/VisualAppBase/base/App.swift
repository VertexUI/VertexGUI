import Dispatch
import Foundation

open class App {
    public var system: System

    public let onSetup = EventHandlerManager<Void>()

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

    /// Will block until exit is executed.
    open func start() throws {
        #if os(macOS)
        try onSetup.invokeHandlers(Void())
        try system.mainLoop() // { $0() }
        RunLoop.main.run()
        #elseif os(Linux)
        DispatchQueue.main.async {
            try! self.onSetup.invokeHandlers(Void())
        }
        try system.mainLoop() // { (_ block: @escaping () -> ()) in
        dispatchMain()
        #else
        fatalError("Unsupported os.")
        #endif
    }
}
