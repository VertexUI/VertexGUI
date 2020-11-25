import CSDL2
import GfxMath
import Dispatch
import Foundation
import VisualAppBase
import WidgetGUI

open class SDL2OpenGL3NanoVGSystem: System {
  public static var windows: [Int: SDL2OpenGL3NanoVGWindow] = [:]

  public static var isRunning = true
  public var targetFps = 60
  public var currentFps = 0
  public static let fpsBufferCount = 100
  public var fpsBuffer = [Int](repeating: 0, count: SDL2OpenGL3NanoVGSystem.fpsBufferCount)  // history of fpsBufferCount fps values
  public var fpsBufferIndex = 0

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

  open func processEvents(timeout: Int) throws {
    var event = SDL_Event()
    var startTime = Int(SDL_GetTicks())

    if SDL2OpenGL3NanoVGSystem.isRunning && SDL_WaitEventTimeout(&event, Int32(timeout)) != 0
    {
      repeat {
        let eventType = SDL_EventType(rawValue: event.type)

        do {
          switch eventType {
          case SDL_QUIT, SDL_APP_TERMINATING:
            try self.exit()

          case SDL_WINDOWEVENT:
            // TODO: implement focus change
            switch event.window.event {
            case UInt8(SDL_WINDOWEVENT_SIZE_CHANGED.rawValue):
              if let window = SDL2OpenGL3NanoVGSystem.windows[Int(event.window.windowID)] {
                window.invalidateSize()
              }
            
            case UInt8(SDL_WINDOWEVENT_MOVED.rawValue):
              if let window = SDL2OpenGL3NanoVGSystem.windows[Int(event.window.windowID)] {
                window.invalidatePosition()
              }

            case UInt8(SDL_WINDOWEVENT_CLOSE.rawValue):
              if let window = SDL2OpenGL3NanoVGSystem.windows[Int(event.window.windowID)] {
                window.close()
              }

            case UInt8(SDL_WINDOWEVENT_FOCUS_GAINED.rawValue):
              if let window = SDL2OpenGL3NanoVGSystem.windows[Int(event.window.windowID)] {
                window.invalidateInputFocus()
              }
            
            case UInt8(SDL_WINDOWEVENT_FOCUS_LOST.rawValue):
              if let window = SDL2OpenGL3NanoVGSystem.windows[Int(event.window.windowID)] {
                window.invalidateInputFocus()
              }

            default:
              break
            }

          case SDL_KEYDOWN:
            if let key = Key(sdlKeycode: event.key.keysym.sym) {
              keyStates[key] = true
              forward(
                KeyDownEvent(
                  key: key, keyStates: self.keyStates, repetition: event.key.repeat != 0),
                windowId: Int(event.key.windowID))
            } else {
              print(
                "Key not mapped from sdl", event.key.keysym.sym, event.key.keysym.scancode,
                event.key.keysym.scancode == SDL_SCANCODE_Y)
            }

          case SDL_TEXTINPUT:
            let text = String(cString: &event.text.text.0)
            forward(TextInputEvent(text), windowId: Int(event.text.windowID))

          case SDL_KEYUP:
            if let key = Key(sdlKeycode: event.key.keysym.sym) {
              keyStates[key] = false
              forward(
                KeyUpEvent(key: key, keyStates: keyStates, repetition: event.key.repeat != 0),
                windowId: Int(event.key.windowID))
            } else {
              print("Key not mapped from sdl", event.key.keysym.sym)
            }

          case SDL_MOUSEBUTTONDOWN:
            let pressedButton: MouseButton
            
            if event.button.button == UInt8(SDL_BUTTON_LEFT) {
              pressedButton = .Left
            } else if event.button.button == UInt8(SDL_BUTTON_RIGHT) {
              pressedButton = .Right
            } else {
              print("sdl mouse button not mapped", event.button.button)
              break
            }
            
            pressedMouseButtons[pressedButton] = true

            forward(
              RawMouseButtonDownEvent(
                button: pressedButton, position: DPoint2(Double(event.button.x), Double(event.button.y))),
              windowId: Int(event.button.windowID))

          case SDL_MOUSEBUTTONUP:
            let pressedButton: MouseButton
            
            if event.button.button == UInt8(SDL_BUTTON_LEFT) {
              pressedButton = .Left
            } else if event.button.button == UInt8(SDL_BUTTON_RIGHT) {
              pressedButton = .Right
            } else {
              print("sdl mouse button not mapped", event.button.button)
              break
            }

            pressedMouseButtons[pressedButton] = false
            forward(
              RawMouseButtonUpEvent(
                button: pressedButton, position: DPoint2(Double(event.button.x), Double(event.button.y))),
              windowId: Int(event.button.windowID))

          case SDL_MOUSEWHEEL:
            forward(
              RawMouseWheelEvent(
                scrollAmount: DVec2(Double(event.wheel.x), Double(event.wheel.y)),
                position: self.mousePosition),
              windowId: Int(event.wheel.windowID))

          case SDL_MOUSEMOTION:
            mousePosition = DPoint2(Double(event.motion.x), Double(event.motion.y))
            forward(
              RawMouseMoveEvent(
                position: mousePosition,
                previousPosition: DPoint2(
                  Double(event.motion.x - event.motion.xrel),
                  Double(event.motion.y - event.motion.yrel))),
              windowId: Int(event.motion.windowID))

          default:
            break
          }

        } catch {
          print("Error while processing event", error)
        }

        event.type = 0
      } while SDL2OpenGL3NanoVGSystem.isRunning && (Int(SDL_GetTicks()) - startTime < timeout)
        && SDL_PollEvent(&event) != 0
    }
  }

  override open func mainLoop() throws {
    DispatchQueue.main.async { [unowned self] in
      if SDL2OpenGL3NanoVGSystem.isRunning {
        do {
          let frameStartTime = SDL_GetTicks()
          let deltaTime = frameStartTime - self.lastFrameTime
          self.lastFrameTime = frameStartTime
          self.currentFps = deltaTime > 0 ? Int(1000 / deltaTime) : 0
          self.fpsBufferIndex += 1
          self.fpsBufferIndex = self.fpsBufferIndex % SDL2OpenGL3NanoVGSystem.fpsBufferCount
          self.fpsBuffer[self.fpsBufferIndex] = self.currentFps

          self.calcAverageFps()
          self.totalTime += deltaTime

          let eventProcessingDuration = max(10, (1000 / self.targetFps))
          try self.processEvents(timeout: eventProcessingDuration)

          self.onTick.invokeHandlers(
            Tick(deltaTime: Double(deltaTime) / 1000, totalTime: currentTime))

          self.onFrame.invokeHandlers(Int(deltaTime))

          let frameDuration = Int(SDL_GetTicks() - frameStartTime)

          try! mainLoop()
        } catch {
          print("Error in main loop", error)
        }
      }
    }
  }

  private func calcAverageFps() {
    averageFps =
      fpsBuffer.reduce(0) {
        $0 + $1
      } / SDL2OpenGL3NanoVGSystem.fpsBufferCount
  }

  override open func exit() {
    SDL2OpenGL3NanoVGSystem.isRunning = false
    Foundation.exit(0)
  }
}
