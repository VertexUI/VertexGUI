import Foundation
import CustomGraphicsMath
import VisualAppBase
import Path
import Swim

public class EventCumulationView: SingleChildWidget {
  private let inspectedRoot: Root

  private var messages = WidgetBus<WidgetInspectionMessage>.MessageBuffer()

  @Reference
  private var canvas: PixelCanvas

  private let minDuration: Double = 40

  private var lineData = LineData()
  private var graphImage = Image(width: 500, height: 300, value: 0)
  private var lastUpdateTimestamp = 0.0
  private let updateInterval = 0.5

  public init(_ inspectedRoot: Root) {
    self.inspectedRoot = inspectedRoot
    super.init()
    self.inspectedRoot.widgetContext!.inspectionBus.pipe(into: messages)
    _ = onTick { [unowned self] _ in
      let currentTimestamp = Date.timeIntervalSinceReferenceDate
      if currentTimestamp - lastUpdateTimestamp > updateInterval {
        checkUpdateGraph()
        lastUpdateTimestamp = currentTimestamp
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

  private func checkUpdateGraph() {
    let previousLineData = lineData
    DispatchQueue.global().async { [weak self] in
      if let self = self {
        self.processMessages()
        if self.lineData != previousLineData {
          self.draw()
          DispatchQueue.main.async { [weak self] in
            if let self = self {
              self.nextTick { _ in
                self.canvas.setContent(self.graphImage)
                self.canvas.invalidateRenderState()
              }
            }
          }
        }
      }
    }
  }

  private func draw() {
    graphImage = Image(width: graphImage.width, height: graphImage.height, value: 0)
    let dataDuration = max(minDuration, lineData.endTimestamp - lineData.startTimestamp)
    for (timestamp, count) in lineData.timeCounts {
      let relativeX = (timestamp - lineData.startTimestamp) / dataDuration
      let relativeY = lineData.maxCount > 0 ? Double(count) / Double(lineData.maxCount) : 1
      let position = SIMD2<Int>(SIMD2<Double>(canvas.contentSize) * [relativeX, relativeY])
      for y in stride(from: canvas.contentSize.y - 1, to: position.y, by: -1) {
        graphImage[position.x, y] = Swim.Color<RGBA, UInt8>(r: 255, g: 255, b: 0, a: 255)
      } 
    }
  }

  private func processMessages() {
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
    messages.clear()
  }
}

extension EventCumulationView {
  struct LineData: Equatable {
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