import Foundation
import ReactiveProperties
import GfxMath
import VisualAppBase
import Path
import Swim

public class EventCumulationView: ComposedWidget {
  internal typealias Event = WidgetInspectionMessage.MessageContent

  private let inspectedRoot: Root

  private var messages = WidgetBus<WidgetInspectionMessage>.MessageBuffer()

  private var cumulatedEvents: [Event] = [
    .BuildInvalidated, .BoxConfigInvalidated, .LayoutInvalidated, .RenderStateInvalidated
  ]

  private var data = CumulationData()
  lazy private var barChartData: [Event: MutableProperty<BarChart.Data>] =
    Dictionary(uniqueKeysWithValues: cumulatedEvents.map { ($0, MutableProperty([])) })

  private var lastUpdateTimestamp = 0.0
  private let updateInterval = 0.5
  private var imageUpdateRunning = false

  public init(_ inspectedRoot: Root) {
    self.inspectedRoot = inspectedRoot
    super.init()

    _ = onDestroy(self.inspectedRoot.widgetContext!.inspectionBus.pipe(into: messages))
    _ = onTick { [unowned self] _ in
      let currentTimestamp = Date.timeIntervalSinceReferenceDate
      if currentTimestamp - lastUpdateTimestamp > updateInterval {
        //checkUpdateGraph()
        lastUpdateTimestamp = currentTimestamp
      }
    }
  }
  
  /*override public func buildChild() -> Widget {
    Row { [unowned self] in
      Experimental.SimpleColumn {
        cumulatedEvents.map { event in
          Experimental.SimpleColumn {
            Text(classes: ["event-name-label"], event.rawValue)
            Container(classes: ["bar-chart-container"]) {
              Experimental.BarChart(barChartData[event]!)
            }.with {
              $0.debugLayout = true
            }
          }
        }
      }.provideStyles([
        Style(".event-name-label-container") {
          ($0.padding, Insets(all: 16))
        },
        Style(".event-name-label", Text.self) {
          ($0.fontSize, 24.0)
        },
        Style(".bar-chart-container", Container.self) {
          ($0.padding, Insets(all: 32))
        }
      ])
    }
  }

  private func checkUpdateGraph() {
    if imageUpdateRunning {
      return
    }
    imageUpdateRunning = true
    let previousData = data
    //let imageSizes: [Event: SIMD2<Int>] = canvases.mapValues { SIMD2([Int($0.referenced!.width), Int($0.referenced!.height)]) }
    DispatchQueue.global().async { [weak self] in
      if let self = self {
        self.processMessages()
        if self.data != previousData {
          //self.draw(imageSizes)
          DispatchQueue.main.async { [weak self] in
            if let self = self {
              self.messages.clear()
              self.imageUpdateRunning = false
              /*self.nextTick { _ in
                for event in self.cumulatedEvents {
                  self.canvases[event]!.referenced!.setContent(self.images[event]!)
                  self.canvases[event]!.referenced!.invalidateRenderState()
                }
              }*/
              //self.invalidateRenderState()
            }
          }
        } else {
          self.imageUpdateRunning = false
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
    messages.clear()

    for event in cumulatedEvents {
      let rawBarChartData = data[event]
      barChartData[event]!.value = rawBarChartData.timeCounts.sorted(by: { $0.0 < $1.0 }).map { (String($0.0), Double($0.1)) }
    }
  }*/
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
