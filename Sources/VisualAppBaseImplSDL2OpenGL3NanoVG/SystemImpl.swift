import WidgetGUI
import CSDL2
import Dispatch
import Foundation
import CustomGraphicsMath
import VisualAppBase

open class SDL2OpenGL3NanoVGSystem: System {
    public static var windows = [Int: SDL2OpenGL3NanoVGWindow]()
    public static var isRunning = true
    //public var targetFps = 60
    public var currentFps = 0
    public static let fpsBufferCount = 100
    public var fpsBuffer = [Int](repeating: 0, count: SDL2OpenGL3NanoVGSystem.fpsBufferCount) // history of fpsBufferCount fps values
    public var fpsBufferIndex = 0
    var lastFrameTime = SDL_GetTicks()
    var totalTime: UInt32 = 0
    
    public var relativeMouseMode = false {
        didSet {
            SDL_SetRelativeMouseMode(relativeMouseMode ? SDL_TRUE : SDL_FALSE)
        }
    }

    public var mousePosition: DPoint2 = DPoint2(0, 0)
    private var pressedMouseButtons = [
        MouseButton.Left: false
    ]

    override public init() throws {
        if SDL_Init(SDL_INIT_VIDEO) != 0 {
            throw SDLError("Unable to initialize SDL.", SDL_GetError())
        }
        //let info = SDL_GetVideoInfo()
        //if (SDL_SetVideoMode(400, 800, info.vfmt.BitsPerPixel, SDL_OPENGL.rawValue) == 0) {
         //   print("Failed to set video mode.")
        //}

        //defer { SDL.quit() }
    }

    override open func updateCursor() {
        if cursorRequests.count > 0 {
            print("HAVE CURSOR REQUEST")
            switch Array(cursorRequests.values)[0] {
            case .Arrow:
                SDL_SetCursor(SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_ARROW))
            case .Hand:
                SDL_SetCursor(SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_HAND))
            default:
                break
            }
        } else {
            SDL_SetCursor(SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_ARROW))
        }
    }

    open func setCursorShown(_ shown: Bool) {
        SDL_ShowCursor(shown ? SDL_ENABLE : SDL_DISABLE)
    }

    open func forward(_ event: RawMouseEvent, windowId: Int) {
        if let window = SDL2OpenGL3NanoVGSystem.windows[windowId] {
            window.onMouse.invokeHandlers(event)
        }
    }

    open func forward(_ event: KeyEvent, windowId: Int) {
        if let window = SDL2OpenGL3NanoVGSystem.windows[windowId] {
            window.onKey.invokeHandlers(event)
        }
    }

    open func forward(_ event: TextEvent, windowId: Int) {
        if let window = SDL2OpenGL3NanoVGSystem.windows[windowId] {
            window.onText.invokeHandlers(event)
        }
    }

    open func processEvents() throws {
        var event = SDL_Event()

        while SDL2OpenGL3NanoVGSystem.isRunning && SDL_PollEvent(&event) != 0 {
            let eventType = SDL_EventType(rawValue: event.type)
            do {
                switch eventType {
                case SDL_QUIT, SDL_APP_TERMINATING:
                    try self.exit()
                case SDL_WINDOWEVENT:
                    // TODO: implement focus change
                    if event.window.event == UInt8(SDL_WINDOWEVENT_SIZE_CHANGED.rawValue) {
                        if let window = SDL2OpenGL3NanoVGSystem.windows[Int(event.window.windowID)] {
                            try window.updateSize()
                        }
                    } else if event.window.event == UInt8(SDL_WINDOWEVENT_CLOSE.rawValue) {
                        if let window = SDL2OpenGL3NanoVGSystem.windows[Int(event.window.windowID)] {
                            window.close()
                        }
                    }
                    break
                case SDL_KEYDOWN:
                    if let key = Key(sdlKeycode: event.key.keysym.sym) {
                        keyStates[key] = true
                        forward(KeyDownEvent(key: key, keyStates: self.keyStates, repetition: event.key.repeat != 0), windowId: Int(event.key.windowID))
                    } else {
                        print("Key not mapped from sdl", event.key.keysym.sym, event.key.keysym.scancode, event.key.keysym.scancode == SDL_SCANCODE_Y)
                    }
                case SDL_TEXTINPUT:
                    var bytes: [UInt8] = []

                    // TODO: this might be slow
                    for (_, value) in Mirror(reflecting: event.text.text).children {
                        let byteValue = UInt8(bitPattern: value as! Int8)
                        if byteValue == 0 {
                            break
                        }
                        bytes.append(byteValue)
                    }

                    if let text = String(data: Data(bytes), encoding: .utf8) {
                        forward(TextInputEvent(text), windowId: Int(event.text.windowID))
                    }
                case SDL_KEYUP:
                    if let key = Key(sdlKeycode: event.key.keysym.sym) {
                        self.keyStates[key] = false
                        try self.forward(KeyUpEvent(key: key, keyStates: self.keyStates, repetition: event.key.repeat != 0), windowId: Int(event.key.windowID))
                    } else {
                        print("Key not mapped from sdl", event.key.keysym.sym)
                    }
                case SDL_MOUSEBUTTONDOWN:
                    self.pressedMouseButtons[.Left] = self.pressedMouseButtons[.Left]! || event.button.button == UInt8(SDL_BUTTON_LEFT)
                    if event.button.button == UInt8(SDL_BUTTON_LEFT) {
                        try self.forward(RawMouseButtonDownEvent(button: .Left, position: DPoint2(Double(event.button.x), Double(event.button.y))), windowId: Int(event.button.windowID))
                    }
                case SDL_MOUSEBUTTONUP:
                    self.pressedMouseButtons[.Left] = event.button.button == UInt8(SDL_BUTTON_LEFT) ? false : self.pressedMouseButtons[.Left]
                    if event.button.button == UInt8(SDL_BUTTON_LEFT) {
                        try self.forward(RawMouseButtonUpEvent(button: .Left, position: DPoint2(Double(event.button.x), Double(event.button.y))), windowId: Int(event.button.windowID))
                    }
                case SDL_MOUSEWHEEL:
                    try self.forward(
                        RawMouseWheelEvent(scrollAmount: DVec2(Double(event.wheel.x), Double(event.wheel.y)), position: self.mousePosition),
                        windowId: Int(event.wheel.windowID))
                case SDL_MOUSEMOTION:
                    self.mousePosition = DPoint2(Double(event.motion.x), Double(event.motion.y))
                    try self.forward(
                        RawMouseMoveEvent(position: self.mousePosition, previousPosition: DPoint2(Double(event.motion.x - event.motion.xrel), Double(event.motion.y - event.motion.yrel))),
                        windowId: Int(event.motion.windowID))
                default:
                    break
                }
            } catch {
                print("Error while processing event", error)
            }

            event.type = 0
        }
    }

    private func calcAverageFps() {
        averageFps = fpsBuffer.reduce(0) {
            $0 + $1
        } / SDL2OpenGL3NanoVGSystem.fpsBufferCount
    }

    override open func mainLoop() throws {
        // TODO: maybe this wrapping function should be given as an argument? --> could be different for different systems/apps
        DispatchQueue.main.async { [unowned self] in
            do {
                // increment ticker
                let currentTime = SDL_GetTicks()
                let deltaTime = currentTime - self.lastFrameTime
                self.currentFps = Int(1000 / deltaTime)
                self.fpsBufferIndex += 1
                self.fpsBufferIndex = self.fpsBufferIndex % SDL2OpenGL3NanoVGSystem.fpsBufferCount
                self.fpsBuffer[self.fpsBufferIndex] = self.currentFps
                self.calcAverageFps()

                self.lastFrameTime = currentTime
                self.totalTime += deltaTime

                try self.processEvents()

                try! self.onFrame.invokeHandlers(Int(deltaTime))

                /*let frameDuration = SDL_GetTicks() - currentTime
                if frameDuration < 1000 / UInt32(self.targetFps) {
                    SDL_Delay((1000 / UInt32(self.targetFps)) - frameDuration)
                }*/

                if SDL2OpenGL3NanoVGSystem.isRunning {
                    try! self.mainLoop()
                } 
            } catch {
                print("Error in main loop", error)
            }
        }
    }

    override open func exit() throws {
        SDL2OpenGL3NanoVGSystem.isRunning = false
        Foundation.exit(0)
    }
}