public struct SDLError: Error {
    public var message: String

    public init(_ message: String, _ sdlErrorMessage: UnsafePointer<Int8>?) {
        self.message = message
        if let sdlErrorMessage = sdlErrorMessage {
            self.message += " " + String(cString: sdlErrorMessage)
        }
    }
}