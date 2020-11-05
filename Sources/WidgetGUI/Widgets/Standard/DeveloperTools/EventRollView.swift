import CustomGraphicsMath

public class EventRollView: SingleChildWidget {
  private let inspectedRoot: Root

  @ObservableProperty
  private var messages: [WidgetInspectionMessage]

  @Reference
  private var canvas: PixelCanvas

  public init(
    _ inspectedRoot: Root,
    messages observableMessages: ObservableProperty<[WidgetInspectionMessage]>) {
    self.inspectedRoot = inspectedRoot
    self._messages = observableMessages
    super.init()
    _ = self.onLayoutingFinished { [unowned self] _ in draw() }
  }
  
  override public func buildChild() -> Widget {
    ConstrainedSize(minSize: DSize2(200, 200)) { [unowned self] in
      PixelCanvas().connect(ref: $canvas)
    }
  }

  private func draw() {
    canvas.setPixel(at: [100, 100], to: .White)
  }
}