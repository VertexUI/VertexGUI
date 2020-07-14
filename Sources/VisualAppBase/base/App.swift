import Dispatch
import Foundation

open class App<S: System<W, R>, W: Window, R: Renderer> {
    public typealias System = S
    public typealias Window = W
    public typealias Renderer = R
    //public typealias RenderContext = VisualAppBase.RenderContext<S, W, R>

    public var system: System?
    //public var renderContext: RenderContext?

    public init() {
        //self.system = system
    }

    /// Setup the system and other app specific things. Should be called by start().
    open func setup() throws {
        fatalError("setup not implemented.")
    }

    open func exit() {
        fatalError("exit not implemented.")
    }

    /// Call setup() and other things necessary to run in the correct DispatchQueue.
    /// Will block until exit is executed.
    open func start() throws {
        DispatchQueue.main.async {
            do {
                try self.setup()
            } catch {
                print("Error in setup()", error)
            }

            do {
                guard let system = self.system else {
                    fatalError("system not initialized after setup() call in start()")
                }
                try system.mainLoop()
            } catch {
                print("Error in system.mainLoop()")
            }
        }

        #if os(macOS)
            CFRunLoopRun()
        #elseif os(Linux)
            dispatchMain()
        #else
            fatalError("Unsupported os.")
        #endif
    }
}