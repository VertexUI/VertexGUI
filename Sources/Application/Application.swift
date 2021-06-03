import Foundation
import CoreFoundation
import WidgetGUI
import HID
import Drawing
import GfxMath
import GL
import SkiaKit
import CSkia

open class Application {
  private var windowBunches: [WindowBunch] = []

  private var event = Event()

  public init() throws {
    Platform.initialize()
    print("Platform version: \(Platform.version)")
  }

  public func createWindow(widgetRoot: Root, graphicsMode: GraphicsMode = .cpu) throws {
    let window: Window
    let canvas: SkiaKit.Canvas

    if graphicsMode == .openGl {
    
      window = try Window(properties: WindowProperties(title: "Title", frame: .init(0, 0, 800, 600)),
                              surface: { try SDLOpenGLWindowSurface(in: $0, with: ()) })

      try window.setupSurface()

      guard let surface = window.surface as? SDLOpenGLWindowSurface else {
        fatalError("no or wrong window surface")
      }

      surface.glContext.makeCurrent()

      guard let skiaSurface = getSkiaSurface(for: surface) else {
        fatalError("could not create skia surface")
      }

      canvas = skiaSurface.canvas

    } else if graphicsMode == .cpu {
      window = try Window(properties: WindowProperties(title: "Title", frame: .init(0, 0, 800, 600)),
                              surface: { try CPUWindowSurface(in: $0) })

      try window.setupSurface()

      guard let surface = window.surface as? CPUWindowSurface else {
        fatalError("no or wrong window surface")
      }

      guard let skiaSurface = getSkiaSurface(for: surface) else {
        fatalError("could not create skia surface")
      }

      canvas = skiaSurface.canvas
    } else {
      fatalError("graphics mode \(graphicsMode) not implemented")
    }

    let drawingBackend = MockDrawingBackend()

    let windowBunch = WindowBunch(window: window, graphicsMode: graphicsMode, widgetRoot: widgetRoot, drawingContext: DrawingContext(backend: drawingBackend), canvas: canvas)

    widgetRoot.setup(
      getKeyStates:  { KeyStatesContainer() },
      getApplicationTime: { 0 },
      getRealFps: { 0 },
      requestCursor: { _ in { () } }
    )

    try updateWindowBunchSize(windowBunch)

    self.windowBunches.append(windowBunch)
  }

  public func start() throws {
    DispatchQueue.main.async { [unowned self] in
      mainLoop()
    }
    dispatchMain()
  }

  private func mainLoop() {
    var quit = false

    Events.pumpEvents()

    while Events.pollEvent(&event) {
      switch event.variant {
        case .userQuit:
          quit = true
        case .window:
          if case let .resizedTo(newSize) = event.window.action {
            if let windowBunch = findWindowBunch(windowId: event.window.windowID) {
              try! updateWindowBunchSize(windowBunch)
            }
          }
        case .textInput:
          print("TEXT INPUT", event)
          forwardEvent(event: event)
        case .textEditing:
          print("text editing", event.textEditing)
        default:
          forwardEvent(event: event)
      }
    }
      
    performNextTickAndFrame()

    if quit {
      Platform.quit()
    } else {
      DispatchQueue.main.async { [unowned self] in
        mainLoop()
      }
    }
  }

  private func forwardEvent(event: Event) {
    switch event.variant {
      case .pointerMotion:
        let eventData = event.pointerMotion
        if let windowBunch = findWindowBunch(windowId: eventData.windowID) {
          let currentPosition = DVec2(Double(eventData.x), Double(eventData.y))
          let delta = DVec2(Double(eventData.deltaX), Double(eventData.deltaY))
          windowBunch.widgetRoot.receive(rawPointerEvent: RawMouseMoveEvent(position: currentPosition, previousPosition: currentPosition - delta))
        }
      
      case .pointerButton:
        let eventData = event.pointerButton

        if let mappedButton = mapPointerButton(eventData.button), let windowBunch = findWindowBunch(windowId: eventData.windowID) {
          let currentPosition = DVec2(Double(eventData.x), Double(eventData.y))

          switch eventData.state {
            case .pressed:
              windowBunch.widgetRoot.receive(rawPointerEvent: RawMouseButtonDownEvent(button: mappedButton, position: currentPosition))
            case .released:
              windowBunch.widgetRoot.receive(rawPointerEvent: RawMouseButtonUpEvent(button: mappedButton, position: currentPosition))
          }
        }
      
      case .pointerScroll:
        let eventData = event.pointerScroll

        if let windowBunch = findWindowBunch(windowId: eventData.windowID) {
          let currentPosition = DVec2(Double(eventData.x), Double(eventData.y))
          windowBunch.widgetRoot.receive(rawPointerEvent: RawMouseWheelEvent(scrollAmount: DVec2(Double(eventData.horizontal), Double(eventData.vertical)), position: currentPosition))
        }
      
      case .textInput:
        let eventData = event.textInput

        if let windowBunch = findWindowBunch(windowId: eventData.windowID) {
          windowBunch.widgetRoot.receive(textInputEvent: RawTextInputEvent(eventData.text))
        }

      default:
        break
    }
  }

  private func mapPointerButton(_ button: HID.PointerButton) -> MouseButton? {
    switch button {
    case .left:
      return .Left
    case .right:
      return .Right
    default:
      return nil
    }
  }

  private func performNextTickAndFrame() {
    for bunch in windowBunches {
      let drawableSize = bunch.window.surface!.getDrawableSize()
      if let surface = bunch.window.surface as? SDLOpenGLWindowSurface {
        surface.glContext.makeCurrent()
        glViewport(0, 0, GLMap.Size(drawableSize.width), GLMap.Size(drawableSize.height))
        glClearColor(1, 1, 1, 1)
        glClear(GLMap.COLOR_BUFFER_BIT)
      }

      bunch.widgetRoot.tick(Tick(deltaTime: 0, totalTime: 0))

      bunch.canvas.clear()
      bunch.canvas.resetMatrix()
      bunch.canvas.flush()

      bunch.widgetRoot.draw(bunch.drawingContext, canvas: bunch.canvas)

      bunch.canvas.flush()

      if let surface = bunch.window.surface as? SDLOpenGLWindowSurface {
        surface.swap()
      } else if let surface = bunch.window.surface as? SDLCPUWindowSurface {
        surface.flush()
      }
    }
  }

  private func updateWindowBunchSize(_ windowBunch: WindowBunch) throws {   
    var skiaSurface: SkiaKit.Surface? = nil
    switch windowBunch.graphicsMode {
    case .cpu:
      guard let windowSurface = windowBunch.window.surface as? SDLCPUWindowSurface else {
        fatalError("incorrect window surface")
      } 

      try windowSurface.handleWindowResize()

      skiaSurface = getSkiaSurface(for: windowSurface)

    case .openGl:
      guard let windowSurface = windowBunch.window.surface as? SDLOpenGLWindowSurface else {
        fatalError("incorrect window surface")
      }

      skiaSurface = getSkiaSurface(for: windowSurface)
    }

    guard let unwrappedSkiaSurface = skiaSurface else {
      fatalError("could not create skia surface")
    }
    windowBunch.canvas = unwrappedSkiaSurface.canvas

    let drawableSize = windowBunch.window.surface!.getDrawableSize()
    windowBunch.widgetRoot.bounds.size = DSize2(Double(drawableSize.width), Double(drawableSize.height))
  }

  private func getSkiaSurface(for surface: SDLOpenGLWindowSurface) -> SkiaKit.Surface? {
    surface.glContext.makeCurrent()

    let surfaceSize = surface.getDrawableSize()

    var buffer: GLMap.Int = 0
    glGetIntegerv(GLMap.DRAW_FRAMEBUFFER_BINDING, &buffer);

    let grContext = GrContext.makeGL(interface: GLInterface.makeNative())

    let glInfo = GrGLFramebufferInfo(fFBOID: UInt32(buffer), fFormat: UInt32(0x8058) /* GR_GL_RGBA8 */)

    let renderTarget = GrBackendRenderTarget(
      width: surfaceSize.width,
      height: surfaceSize.height,
      samples: 0,
      stencils: 8,
      glInfo: glInfo)

    let skiaSurface = SkiaKit.Surface.makeFromBackendRenderTarget(
      context: grContext,
      target: renderTarget,
      origin: .bottomLeft,
      colorType: .rgba8888,
      colorSpace: nil,
      props: SurfaceProperties(.rgbHorizontal))

    return skiaSurface
  }

  private func getSkiaSurface(for surface: CPUWindowSurface) -> SkiaKit.Surface? {
    let surfaceSize = surface.getDrawableSize()

    let surfaceImageInfo = ImageInfo(
      width: Int32(surfaceSize.width),
      height: Int32(surfaceSize.height),
      colorType: .bgra8888,
      alphaType: .unpremul
    )

    if let skiaSurface = SkiaKit.Surface.make(
      surfaceImageInfo,
      UnsafeMutableRawPointer(surface.buffer.baseAddress!),
      surfaceSize.width * 4) {

      return skiaSurface
    }

    return nil
  }

  private func findWindowBunch(windowId: Int) -> WindowBunch? {
    windowBunches.first { $0.window.windowID == windowId }
  }
}

extension Application {
  public class WindowBunch {
    public var window: HID.Window
    public var graphicsMode: GraphicsMode
    public var widgetRoot: Root
    public var drawingContext: DrawingContext
    public var canvas: SkiaKit.Canvas

    public init(window: HID.Window, graphicsMode: GraphicsMode, widgetRoot: Root, drawingContext: DrawingContext, canvas: SkiaKit.Canvas) {
      self.window = window
      self.graphicsMode = graphicsMode
      self.widgetRoot = widgetRoot
      self.drawingContext = drawingContext
      self.canvas = canvas
    }
  }

  public enum GraphicsMode {
    case openGl, cpu
  }
}