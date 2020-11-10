import Foundation
import CustomGraphicsMath
import VisualAppBase
import Path
import Swim

public class EventCumulationView: SingleChildWidget {
  private typealias Event = WidgetInspectionMessage.MessageContent

  private let inspectedRoot: Root

  private var messages = WidgetBus<WidgetInspectionMessage>.MessageBuffer()

  private var cumulatedEvents: [Event] = [
    .BuildInvalidated, .BoxConfigInvalidated, .LayoutInvalidated, .RenderStateInvalidated
  ]

  private var canvases: [Event: Reference<PixelCanvas>] = [:]

  private var data = CumulationData()
  private let minDuration: Double = 40
  private var startTimestamp: Double = -1
  private var endTimestamp: Double = -1

  private var images: [Event: VisualAppBase.Image] = [:]
  private var lastUpdateTimestamp = 0.0
  private let updateInterval = 0.5

  public init(_ inspectedRoot: Root) {
    self.inspectedRoot = inspectedRoot
    super.init()

    for event in cumulatedEvents {
      canvases[event] = Reference()
      images[event] = Image(width: 600, height: 200, value: 0)
    }


    _ = onDestroy(self.inspectedRoot.widgetContext!.inspectionBus.pipe(into: messages))
    _ = onTick { [unowned self] _ in
      let currentTimestamp = Date.timeIntervalSinceReferenceDate
      if currentTimestamp - lastUpdateTimestamp > updateInterval {
        checkUpdateGraph()
        lastUpdateTimestamp = currentTimestamp
      }
    }
  }
  
  override public func buildChild() -> Widget {
    Row(wrap: true) { [unowned self] in
      cumulatedEvents.map { event in
        Row.Item(margins: Margins(right: 32, bottom: 32)) {
          Column(spacing: 16) {
            Text("Counts for event: \(event)")
            ConstrainedSize(minSize: DSize2(200, 200)) {
              PixelCanvas(DSize2(300, 200)).connect(ref: canvases[event]!).with {
                $0.debugLayout = true
              }
            }
          }
        }
      }
    }
  }

  private func checkUpdateGraph() {
    let previousData = data
    DispatchQueue.global().async { [weak self] in
      if let self = self {
        self.processMessages()
        if self.data != previousData {
          self.draw()
          DispatchQueue.main.async { [weak self] in
            if let self = self {
              self.messages.clear()
              self.nextTick { _ in
                for event in self.cumulatedEvents {
                  self.canvases[event]!.referenced!.setContent(self.images[event]!)
                  self.canvases[event]!.referenced!.invalidateRenderState()
                }
              }
            }
          }
        }
      }
    }
  }

  private func draw() {
    let dataDuration = max(minDuration, data.maxTimestamp - data.minTimestamp)
    for event in cumulatedEvents {
      images[event] = Image(width: images[event]!.width, height: images[event]!.height, value: 0)
      
      let eventData = data[event]

      for (timestamp, count) in eventData.timeCounts {
        let relativeX = dataDuration > 0 ? (timestamp - data.minTimestamp) / dataDuration : 0
        let relativeY = eventData.maxCount > 0 ? Double(count) / Double(eventData.maxCount) : 1
        let position = SIMD2<Int>(SIMD2<Double>([images[event]!.width - 1, images[event]!.height - 1]) * [relativeX, relativeY])
        for y in stride(from: images[event]!.height - 1, to: position.y, by: -1) {
          images[event]![position.x, y] = Swim.Color<RGBA, UInt8>(r: 255, g: 255, b: 0, a: 255)
        }
      }
    }
  }

  private func processMessages() {
    for message in messages {
      for event in cumulatedEvents {
        if message.content == event {
          data.count(event, timestamp: message.timestamp)
          break
        }
      }
    }
  }

  override public func renderContent() -> RenderObject {
    ContainerRenderObject {
      super.renderContent()
      CustomRenderObject(id: 1) { _ in }
    }
  }

  override public func destroySelf() {
    super.destroySelf()
  }
}

extension EventCumulationView {
  struct CumulationData: Equatable {
    private var eventData: [WidgetInspectionMessage.MessageContent: EventData] = [:]
    private(set) var minTimestamp: Double = -1
    private(set) var maxTimestamp: Double = -1
    
    subscript(_ event: WidgetInspectionMessage.MessageContent) -> EventData {
      eventData[event] ?? EventData()
    }

    mutating func count(_ event: WidgetInspectionMessage.MessageContent, timestamp: Double) {
      let aggregatedTimestamp = round(timestamp)
      if eventData[event] == nil {
        eventData[event] = EventData()
      }
      eventData[event]!.increment(aggregatedTimestamp)

      if aggregatedTimestamp < minTimestamp || minTimestamp == -1 {
        minTimestamp = aggregatedTimestamp
      }
      if aggregatedTimestamp > maxTimestamp || maxTimestamp == -1 {
        maxTimestamp = aggregatedTimestamp
      }
    }
  }

  struct EventData: Equatable {
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

    mutating func increment(_ timestamp: Double) {
      if timeCounts[timestamp] == nil {
        timeCounts[timestamp] = 0
      }
      timeCounts[timestamp]! += 1
    }
  }
}
