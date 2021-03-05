import ReactiveProperties
import VisualAppBase

extension DeveloperTools {
  public class PerformanceView: ContentfulWidget {
    @Inject
    var inspectedRoot: Root

    var barChartData = ObservableDictionary(ChartContent.allCases.reduce(into: [:]) {
      $0[$1] = BarChart.Data()
    })

    override public init() {
      super.init()
      _ = onDependenciesInjected { [unowned self] in
        onTick {
          updateBarChartData()
        }
      }
    }

    @ExpDirectContentBuilder override public var content: ExpDirectContent {
      Container().withContent { [unowned self] in
        Container().with(classes: ["chart-group"]).experimentalWith(styleProperties: {
          (\.$direction, .column)
        }).withContent {
          buildChart(.processMouseEvent)
          buildChart(.processKeyEvent)
          buildChart(.processTextEvent)
        }

        Container().with(classes: ["chart-group"]).experimentalWith(styleProperties: {
          (\.$direction, .column)
        }).withContent {
          buildChart(.tick)
          buildChart(.build)
          buildChart(.updateChildren)
          buildChart(.resolveMatchedStyles)
          buildChart(.resolveStyleProperties)
          buildChart(.layout)
          buildChart(.updateCumulatedValues)
        }

        buildChart(.draw).experimentalWith(styleProperties: {
          (\.$margin, Insets(bottom: 16))
        })
      }
    }

    func buildChart(_ content: ChartContent) -> Widget {
      Container().experimentalWith(styleProperties: {
        (\.$direction, .column)
      }).withContent {
        Text(content.rawValue).with(classes: ["chart-title"])

        BarChart(Experimental.ImmutableBinding(barChartData.bindings[content].immutable, get: { $0 ?? [] })).with(classes: ["chart"])
      }
    }

    func updateBarChartData() {
      var updatedBarChartData = ChartContent.allCases.reduce(into: [ChartContent: BarChart.Data]()) {
        $0[$1] = []
      }

      for operation in inspectedRoot.debugManager.data.operations {
        switch operation {
        case let operation as Root.ProcessMouseEventOperationDebugData:
          updatedBarChartData[.processMouseEvent]!.append((label: "wow", operation.duration))

        case let operation as Root.ProcessKeyEventOperationDebugData:
          updatedBarChartData[.processKeyEvent]!.append((label: "wow", operation.duration))

        case let operation as Root.ProcessTextEventOperationDebugData:
          updatedBarChartData[.processTextEvent]!.append((label: "wow", operation.duration))

        case let operation as Root.TickOperationDebugData: 
          updatedBarChartData[.tick]!.append((label: "wow", operation.duration))

          updatedBarChartData[.build]!.append((label: "wow", operation.steps[.build]!.duration))
          updatedBarChartData[.updateChildren]!.append((label: "wow", operation.steps[.updateChildren]!.duration))
          updatedBarChartData[.resolveMatchedStyles]!.append((label: "wow", operation.steps[.resolveMatchedStyles]!.duration))
          updatedBarChartData[.resolveStyleProperties]!.append((label: "wow", operation.steps[.resolveStyleProperties]!.duration))
          updatedBarChartData[.layout]!.append((label: "wow", operation.steps[.layout]!.duration))
          updatedBarChartData[.updateCumulatedValues]!.append((label: "wow", operation.steps[.updateCumulatedValues]!.duration))

        case let operation as Root.DrawOperationDebugData:
          updatedBarChartData[.draw]!.append((label: "draw", value: operation.duration))

        default:
          break
        }
      }

      for chartContent in barChartData.keys {
        barChartData[chartContent] = updatedBarChartData[chartContent]
      }
    }

    override public var experimentalStyle: Experimental.Style {
      Experimental.Style("&") {} nested: {
        Experimental.Style(".chart-group") {
          (\.$margin, Insets(right: 16))
        }

        Experimental.Style(".chart-title") {
          (\.$fontWeight, .bold)
        }

        Experimental.Style(".chart") {
          (\.$alignSelf, .stretch)
          (\.$height, 200)
          (\.$width, 400)
          (\.$margin, Insets(bottom: 16))
        }
      }
    }

    enum ChartContent: String, CaseIterable {
      case processMouseEvent, processKeyEvent, processTextEvent, tick, build, updateChildren, resolveMatchedStyles, resolveStyleProperties, layout, updateCumulatedValues, draw
    }
  }
}