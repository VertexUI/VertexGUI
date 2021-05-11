import WidgetGUI
import HID
import Drawing
import DrawingImplGL3NanoVG

open class Application {
  private var windowBunches: [WindowBunch] = []

  public init() throws {
    Platform.initialize()
    print("Platform version: \(Platform.version)")
  }

  public func createWindow(widgetRoot: Root) throws {

    // either use a custom surface sub-class
    // or use the default implementation directly
    // let surface = CPUSurface()
    let window = try Window(properties: WindowProperties(title: "Title", frame: .init(0, 0, 800, 600)),
                            surface: { try OpenGLWindowSurface(in: $0, with: ()) })

    try window.setupSurface()

    guard let surface = window.surface as? OpenGLWindowSurface else {
        fatalError("no window surface")
    }

    let drawingBackend = GL3NanoVGDrawingBackend(surface: surface)

    let windowBunch = WindowBunch(window: window, widgetRoot: widgetRoot, drawingContext: DrawingContext(backend: drawingBackend))

    self.windowBunches.append(windowBunch)
  }

  public func start() throws {
    mainLoop()
  }

  private func mainLoop() {
    var event = Event()

    var quit = false

    while !quit {
        Events.pumpEvents()

        while Events.pollEvent(&event) {
            switch event.variant {
            case .userQuit:
                quit = true

            case .window:
                if case let .resizedTo(newSize) = event.window.action {

                }

            default:
                break
            }
        }
    }

    Platform.quit()
  }
}

extension Application {
  public class WindowBunch {
    public var window: Window
    public var widgetRoot: Root
    public var drawingContext: DrawingContext

    public init(window: Window, widgetRoot: Root, drawingContext: DrawingContext) {
      self.window = window
      self.widgetRoot = widgetRoot
      self.drawingContext = drawingContext
    }
  }
}