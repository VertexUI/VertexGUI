import Application
import CSDL2
import GfxMath
import Dispatch
import Foundation
import OpenCombine

public class ApplicationBackendSDL2: ApplicationBackend {
  private static var instance: ApplicationBackendSDL2? = nil
  public static var windows: [Int: SDL2BaseWindow] = [:]

  public static var isRunning = true
  public static var keyStates = KeyStatesContainer()

  public let eventPublisher = PassthroughSubject<ApplicationEvent, Never>()
  /*public var targetFps = 60
  private var _realFps: Double = 0
  override public var realFps: Double {
    _realFps
  }
  private static let fpsBufferCount = 30 
  private var fpsBuffer = [Double](repeating: 0, count: SDL2OpenGL3NanoVGSystem.fpsBufferCount)  // history of fpsBufferCount fps values
  private var fpsBufferIndex = 0

  var lastFrameTime = SDL_GetTicks()
  var totalTime: UInt32 = 0  // in ms

  override open var currentTime: Double {  // in s
    return Double(totalTime) / 1000
  }

  public var relativeMouseMode = false {
    didSet {
      SDL_SetRelativeMouseMode(relativeMouseMode ? SDL_TRUE : SDL_FALSE)
    }
  }

  public var mousePosition: DPoint2 = DPoint2(0, 0)

  private var pressedMouseButtons = [
    MouseButton.Left: false
  ]*/

  public init() {
    if SDL_Init(SDL_INIT_VIDEO) != 0 {
      //throw SDLError("Unable to initialize SDL.", SDL_GetError())
    }

    //let info = SDL_GetVideoInfo()
    //if (SDL_SetVideoMode(400, 800, info.vfmt.BitsPerPixel, SDL_OPENGL.rawValue) == 0) {
    //   print("Failed to set video mode.")
    //}

    //defer { SDL.quit() }
  }

  public static func getInstance() throws -> ApplicationBackendSDL2 {
    if let instance = instance {
      return instance
    } else {
      instance = try ApplicationBackendSDL2()
      return instance!
    }
  }

  public func setup() {}

  public var relativeMouseModeEnabled: Bool {
    get {
      SDL_GetRelativeMouseMode() == SDL_TRUE
    }
    set {
      SDL_SetRelativeMouseMode(newValue ? SDL_TRUE : SDL_FALSE)
    }
  }

  /*override open func updateCursor() {
    if cursorRequests.count > 0 {
      print("HAVE CURSOR REQUEST")
      let cursor = Array(cursorRequests.values)[0]
      switch cursor {
      case .Arrow:
        SDL_SetCursor(SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_ARROW))

      case .Hand:
        SDL_SetCursor(SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_HAND))

      case .Text:
        SDL_SetCursor(SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_IBEAM))
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
  */
  open func processEvents() throws {
    try processEvents(timeout: 0)
  }

  open func processEvents(timeout: Double) throws {
    let timeoutMs = Int(timeout * 1000)

    var event = SDL_Event()
    var startTime = Int(SDL_GetTicks())

    if ApplicationBackendSDL2.isRunning &&
      (timeout != 0 
      ? SDL_WaitEventTimeout(&event, Int32(timeoutMs)) != 0
      : SDL_PollEvent(&event) != 0)
    {
      repeat {
        let eventType = SDL_EventType(rawValue: event.type)

        do {
          switch eventType {
          case SDL_QUIT, SDL_APP_TERMINATING:
            eventPublisher.send(.quit)
            try self.exit()

          case SDL_WINDOWEVENT:
            // TODO: implement focus change
            switch event.window.event {
            case UInt8(SDL_WINDOWEVENT_SIZE_CHANGED.rawValue):
              if let window = Self.windows[Int(event.window.windowID)] {
                window.notifySizeChanged()
              }
            
            case UInt8(SDL_WINDOWEVENT_MOVED.rawValue):
              if let window = Self.windows[Int(event.window.windowID)] {
                //window.invalidatePosition()
              }

            case UInt8(SDL_WINDOWEVENT_CLOSE.rawValue):
              if let window = Self.windows[Int(event.window.windowID)] {
                window.close()
              }

            case UInt8(SDL_WINDOWEVENT_FOCUS_GAINED.rawValue):
              if let window = Self.windows[Int(event.window.windowID)] {
                //window.invalidateInputFocus()
              }
            
            case UInt8(SDL_WINDOWEVENT_FOCUS_LOST.rawValue):
              if let window = Self.windows[Int(event.window.windowID)] {
                //window.invalidateInputFocus()
              }

            default:
              break
            }

          case SDL_KEYDOWN:
            if let window = Self.windows[Int(event.key.windowID)], let key = Key(sdlKeycode: event.key.keysym.sym) {
              Self.keyStates[key] = true
                window.inputEventPublisher.send(WindowKeyDownEvent(
                  key: key, keyStates: Self.keyStates, repetition: event.key.repeat != 0))
            } else {
              print(
                "Key not mapped from sdl", event.key.keysym.sym, event.key.keysym.scancode,
                event.key.keysym.scancode == SDL_SCANCODE_Y)
            }

          case SDL_TEXTINPUT:
            if let window = Self.windows[Int(event.text.windowID)] {
              let text = String(cString: &event.text.text.0)
              window.inputEventPublisher.send(WindowTextInputEvent(text: text))
            }

          case SDL_KEYUP:
            if let window = Self.windows[Int(event.key.windowID)], let key = Key(sdlKeycode: event.key.keysym.sym) {
              Self.keyStates[key] = false
              window.inputEventPublisher.send(WindowKeyUpEvent(key: key, keyStates: Self.keyStates))
            } else {
              print("Key not mapped from sdl", event.key.keysym.sym)
            }

          case SDL_MOUSEBUTTONDOWN:
            if let window = Self.windows[Int(event.button.windowID)] {
              window.inputEventPublisher.send(WindowMouseButtonDownEvent(
                button: MouseButton(fromSDL: event.button.button)))
            }

          case SDL_MOUSEBUTTONUP:
            //pressedMouseButtons[pressedButton] = false
            if let window = Self.windows[Int(event.button.windowID)] {
              window.inputEventPublisher.send(WindowMouseButtonUpEvent(
                button: MouseButton(fromSDL: event.button.button)))
            }
            /*forward(
              RawMouseButtonUpEvent(
                button: pressedButton, position: DPoint2(Double(event.button.x), Double(event.button.y))),
              windowId: Int(event.button.windowID))*/
          /*
          case SDL_MOUSEWHEEL:
            forward(
              RawMouseWheelEvent(
                scrollAmount: DVec2(Double(event.wheel.x), Double(event.wheel.y)),
                position: self.mousePosition),
              windowId: Int(event.wheel.windowID))*/

          case SDL_MOUSEMOTION:
            if let window = Self.windows[Int(event.motion.windowID)] {
              let position = DPoint2(Double(event.motion.x), Double(event.motion.y))
              let positionDelta = DPoint2(Double(event.motion.xrel), Double(event.motion.yrel))
              window.inputEventPublisher.send(
                WindowMouseMoveEvent(position: position, positionDelta: positionDelta)
              )
            }
            /*forward(
              RawMouseMoveEvent(
                position: mousePosition,
                previousPosition: DPoint2(
                  Double(event.motion.x - event.motion.xrel),
                  Double(event.motion.y - event.motion.yrel))),
              windowId: Int(event.motion.windowID))*/

          default:
            break
          }

        } catch {
          print("Error while processing event", error)
        }

        event.type = 0
      } while Self.isRunning && (timeoutMs > 0 ? (Int(SDL_GetTicks()) - startTime < timeoutMs) : true)
        && SDL_PollEvent(&event) != 0
    }
  }
  /*
  override open func mainLoop() throws {
    DispatchQueue.main.async { [unowned self] in
      if SDL2OpenGL3NanoVGSystem.isRunning {
        do {
          let frameStartTime = SDL_GetTicks()
          let deltaTime = frameStartTime - self.lastFrameTime
          self.totalTime += deltaTime
          self.lastFrameTime = frameStartTime
 
          let singleFrameFps = deltaTime > 0 ? 1000 / Double(deltaTime) : 0
          self.fpsBufferIndex += 1
          self.fpsBufferIndex = self.fpsBufferIndex % SDL2OpenGL3NanoVGSystem.fpsBufferCount
          self.fpsBuffer[self.fpsBufferIndex] = singleFrameFps 

          self.calcRealFps()

          var startTime = Date.timeIntervalSinceReferenceDate
          let eventProcessingDuration = max(10, (1000 / self.targetFps))
          try self.processEvents(timeout: eventProcessingDuration)
          //print("EVENT PROCESSSING TOOK", Date.timeIntervalSinceReferenceDate - startTime)

          startTime = Date.timeIntervalSinceReferenceDate
          self.onTick.invokeHandlers(
            Tick(deltaTime: Double(deltaTime) / 1000, totalTime: currentTime))
          //print("ON TICK TOOK", Date.timeIntervalSinceReferenceDate - startTime)

          //self.onFrame.invokeHandlers(Double(deltaTime / 1000))
          // TODO: maybe call onFrame on windows through system's onFrame handler?
          startTime = Date.timeIntervalSinceReferenceDate
          for window in SDL2OpenGL3NanoVGSystem.windows.values {
            window.performFrame(Double(deltaTime / 1000))
          }
          //print("ON FRAME TOOK", Date.timeIntervalSinceReferenceDate - startTime)

          let frameDuration = Int(SDL_GetTicks() - frameStartTime)
          try! mainLoop()
        } catch {
          print("Error in main loop", error)
        }
      }
    }
  }

  private func calcRealFps() {
    _realFps =
      fpsBuffer.reduce(0.0) {
        $0 + $1
      } / Double(SDL2OpenGL3NanoVGSystem.fpsBufferCount)
  }
  */
  public func exit() {
    ApplicationBackendSDL2.isRunning = false
    Foundation.exit(0)
  }
}