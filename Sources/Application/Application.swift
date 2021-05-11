import WidgetGUI
import HID
import VisualAppBase
import Drawing
import DrawingImplGL3NanoVG
import GfxMath

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

    widgetRoot.setup(
      measureText: { _, _ in .zero },
      getKeyStates:  { KeyStatesContainer() },
      getApplicationTime: { 0 },
      getRealFps: { 0 },
      requestCursor: { _ in { () } }
    )

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

        for bunch in windowBunches {
          bunch.widgetRoot.tick(Tick(deltaTime: 0, totalTime: 0))
          let windowSize = bunch.window.surface!.getDrawableSize()
          bunch.drawingContext.drawRect(rect: DRect(min: DVec2(0, 0), max: DVec2(Double(windowSize.width), Double(windowSize.height))), paint: Paint(color: .black))
          bunch.drawingContext.backend.activate()
          bunch.widgetRoot.draw(bunch.drawingContext)
          bunch.drawingContext.backend.deactivate()
          if let surface = bunch.window.surface as? SDLOpenGLWindowSurface {
            surface.swap()
          }
        }
    }

    Platform.quit()
  }
}

extension Application {
  public class WindowBunch {
    public var window: HID.Window
    public var widgetRoot: Root
    public var drawingContext: DrawingContext

    public init(window: HID.Window, widgetRoot: Root, drawingContext: DrawingContext) {
      self.window = window
      self.widgetRoot = widgetRoot
      self.drawingContext = drawingContext
    }
  }
}