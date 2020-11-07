import Foundation
import CustomGraphicsMath
import VisualAppBase
import Path

public class EventRollView: SingleChildWidget {
  private let inspectedRoot: Root

  private var messages: WidgetBus<WidgetInspectionMessage>.MessageBuffer

  private var messagesUpdated: Bool = false

  @Reference
  private var canvas: PixelCanvas

  private let minDuration: Double = 40

  private var lineData = LineData() 

  public init(
    _ inspectedRoot: Root,
    messageBuffer: WidgetBus<WidgetInspectionMessage>.MessageBuffer) {
    self.inspectedRoot = inspectedRoot
    self.messages = messageBuffer
    super.init()
    //_ = self.onMounted { [unowned self] _ in draw() }
    _ = onDestroy(self.messages.onUpdated { [unowned self] _ in
      messagesUpdated = true
      //processMessages()
    })
    _ = onTick { [unowned self] _ in
      if messagesUpdated {
        processMessages()
        draw()
        messagesUpdated = false
      }
    }
  }
  
  override public func buildChild() -> Widget {
    ConstrainedSize(minSize: DSize2(200, 200)) { [unowned self] in
      PixelCanvas(DSize2(300, 200)).connect(ref: $canvas).with {
        $0.debugLayout = true
      }
    }
  }

  private func draw() {
    canvas.clear()
    let dataDuration = max(minDuration, lineData.endTimestamp - lineData.startTimestamp)
    for (timestamp, count) in lineData.timeCounts {
      let relativeX = (timestamp - lineData.startTimestamp) / dataDuration
      let relativeY = lineData.maxCount > 0 ? Double(count) / Double(lineData.maxCount) : 1
      let position = SIMD2<Int>(SIMD2<Double>(canvas.contentSize) * [relativeX, relativeY])
      for y in stride(from: canvas.contentSize.y - 1, to: position.y, by: -1) {
        canvas.setPixel(at: [position.x, y], to: Color.Yellow)
      } 
    }
    canvas.invalidateRenderState()
  }

  private func processMessages() {
    lineData = LineData()
    for message in messages {
      switch message.content {
      case .LayoutInvalidated:
        let aggregationTimestamp = floor(message.timestamp)
        if lineData.timeCounts[aggregationTimestamp] == nil {
          lineData.timeCounts[aggregationTimestamp] = 0
        }
        lineData.timeCounts[aggregationTimestamp]! += 1
      default: break
      }

      if lineData.startTimestamp == -1 || lineData.startTimestamp > message.timestamp {
        lineData.startTimestamp = message.timestamp
      }
      if lineData.endTimestamp == -1 || lineData.endTimestamp < message.timestamp {
        lineData.endTimestamp = message.timestamp
      }
    }
  }
}

extension EventRollView {
  struct LineData {
    var startTimestamp: Double = -1
    var endTimestamp: Double = -1
    var timeCounts: [Double: UInt] = [:]
    var minCount: UInt {
      var min: UInt? = nil
      for value in timeCounts.values {
        if min == nil || value < min! {
          min = value
        }
      }
      return min ?? 0
    }
    var maxCount: UInt {
      var max: UInt = 0
      for value in timeCounts.values {
        if value > max {
          max = value
        }
      }
      return max
    }
  }
}