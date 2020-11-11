import Foundation
import CustomGraphicsMath
import VisualAppBase
import Path
import Swim

public class EventCumulationView: SingleChildWidget {
  internal typealias Event = WidgetInspectionMessage.MessageContent

  private let inspectedRoot: Root

  private var messages = WidgetBus<WidgetInspectionMessage>.MessageBuffer()

  private var cumulatedEvents: [Event] = [
    .BuildInvalidated, .BoxConfigInvalidated, .LayoutInvalidated, .RenderStateInvalidated
  ]

  private var canvases: [Event: Reference<PixelCanvas>] = [:]
  @Reference
  private var xLegendSpace: Space
  @Reference
  private var yLegendSpace: Space

  private var data = CumulationData()
  private let minDuration: Double = 40
  private var startTimestamp: Double = -1
  private var endTimestamp: Double = -1

  private var images: [Event: VisualAppBase.Image] = [:]
  private var lastUpdateTimestamp = 0.0
  private let updateInterval = 0.5
  private var imageUpdateRunning = false

  private let graphTitleFontConfig = Text.defaultConfig.fontConfig
  private let scaleTickFontConfig = Text.defaultConfig.fontConfig

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
    Row { [unowned self] in
      Space(context.getTextBoundsSize("1000", fontConfig: scaleTickFontConfig)).connect(ref: $yLegendSpace)

      Column {
        cumulatedEvents.map { event in
          //Text("Counts for event: \(event)")
          ConstrainedSize(minSize: DSize2(200, 100)) {
            PixelCanvas(DSize2(300, 200)).connect(ref: canvases[event]!).with {
              $0.debugLayout = true
            }
          }
        }

        Column.Item(margins: Margins(top: 16)) {
          Space(context.getTextBoundsSize("WOWO", fontConfig: scaleTickFontConfig)).connect(ref: $xLegendSpace)
        }
      }
    }
  }

  private func checkUpdateGraph() {
    if imageUpdateRunning {
      return
    }
    imageUpdateRunning = true
    let previousData = data
    let imageSizes: [Event: SIMD2<Int>] = canvases.mapValues { SIMD2([Int($0.referenced!.width), Int($0.referenced!.height)]) }
    DispatchQueue.global().async { [weak self] in
      if let self = self {
        self.processMessages()
        if self.data != previousData {
          self.draw(imageSizes)
          DispatchQueue.main.async { [weak self] in
            if let self = self {
              self.messages.clear()
              self.imageUpdateRunning = false
              self.nextTick { _ in
                for event in self.cumulatedEvents {
                  self.canvases[event]!.referenced!.setContent(self.images[event]!)
                  self.canvases[event]!.referenced!.invalidateRenderState()
                }
              }
              self.invalidateRenderState()
            }
          }
        } else {
          self.imageUpdateRunning = false
        }
      }
    }
  }

  private func draw(_ imageSizes: [Event: SIMD2<Int>]) {
    let dataDuration = max(minDuration, data.maxTimestamp - data.minTimestamp)
    for event in cumulatedEvents {
      images[event] = Image(width: imageSizes[event]!.x, height: imageSizes[event]!.y, value: 0)
      
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
    var timestampLabels = [(timestamp: Double, x: Double)]()

    let minTimestamp = 0
    let maxTimestamp = max(minDuration, data.maxTimestamp - data.minTimestamp)

    let labelSize = context.getTextBoundsSize(String(maxTimestamp), fontConfig: scaleTickFontConfig)

    let labelCount = max(2, Int(xLegendSpace.width / labelSize.width / 2))

    for i in 0..<labelCount {
      let factor = Double(i) / Double(labelCount - 1)
      let timestamp = round(maxTimestamp * factor * 100) / 100
      let labelSize = context.getTextBoundsSize(String(timestamp), fontConfig: scaleTickFontConfig)
      timestampLabels.append((timestamp: timestamp, x: factor * xLegendSpace.width - labelSize.width / 2))
    }

    var yLabels = [(label: String, position: DPoint2)]()
    for event in cumulatedEvents {
      let eventData = data[event]
      let canvas = canvases[event]!.referenced!

      let labelSize = context.getTextBoundsSize(String(1000), fontConfig: scaleTickFontConfig)

      let yMin = canvas.globalPosition.y + labelSize.height / 2
      let yMax = canvas.globalPosition.y + canvas.height - labelSize.height / 2
      let yDelta = yMax - yMin

      let labelCount = max(Int(yDelta / labelSize.height), 2)

      for i in 0..<labelCount {
        let factor = Double(i) / Double(labelCount - 1)
        let label = String(Int(Double(eventData.maxCount) * factor))
        let y = yMin + (yDelta - labelSize.height) * factor
        yLabels.append((label: label, position: DPoint2(yLegendSpace.globalPosition.x, y)))
      }
    }

    var graphLabels = [(label: String, position: DPoint2)]()
    for event in cumulatedEvents {
      let canvas = canvases[event]!.referenced!
      let labelPosition = canvas.globalPosition + DVec2(16, 16)
      graphLabels.append((label: String(describing: event), position: labelPosition))
    }

    return ContainerRenderObject {
      super.renderContent() 
      
      timestampLabels.map {
        TextRenderObject(String($0.timestamp), fontConfig: scaleTickFontConfig, color: .Black, topLeft: xLegendSpace.globalPosition + DVec2($0.x, 0))
      }

      yLabels.map {
        TextRenderObject($0.label, fontConfig: scaleTickFontConfig, color: .Black, topLeft: $0.position)
      }

      graphLabels.map {
        TextRenderObject(String($0.label), fontConfig: scaleTickFontConfig, color: .Black, topLeft: $0.position)
      }
    }
  }

  override public func destroySelf() {
    super.destroySelf()
  }
}

extension EventCumulationView {
  struct CumulationData: Equatable {
    private var eventData: [Event: EventData] = [:]
    private(set) var minTimestamp: Double = -1
    private(set) var maxTimestamp: Double = -1
    
    subscript(_ event: Event) -> EventData {
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
  /*
  class UnlayoutedContainer: Widget {
    private let childrenBuilder: () -> [Widget]
    
    public init(@WidgetBuilder children childrenBuilder: @escaping () -> [Widget]) {
      self.childrenBuilder = childrenBuilder
    }

    override public func performBuild() {
      self.children = childrenBuilder()
    }

    override public func getBoxConfig() {
      BoxConfig(preferredSize: .zero)
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      var size = DSize2.zero

      for child in children {
        if child.x + child.width > size.width {
          size.width = child.x + child.width
        }
        if child.y + child.height > size.height {
          size.height = child.y + child.height
        }
      }

      return size
    }
  }*/
}
