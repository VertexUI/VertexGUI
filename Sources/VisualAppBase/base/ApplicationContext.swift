import Foundation
import GfxMath

public class ApplicationContext {
    public var system: System
    public var window: Window

    public init(system: System, window: Window) {
        self.system = system
        self.window = window
    }
}