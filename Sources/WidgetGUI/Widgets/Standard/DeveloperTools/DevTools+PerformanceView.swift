import ReactiveProperties
import VisualAppBase

extension DeveloperTools {
  public class PerformanceView: ContentfulWidget {
    @Inject
    var inspectedRoot: Root

    var barChartDataProperties: [ChartContent: MutableProperty<BarChart.Data>] = ChartContent.allCases.reduce(into: [:]) {
        $0[$1] = MutableProperty([])
      }

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
        Container().with(classes: ["chart-group"]).with(styleProperties: { _ in
          (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
        }).withContent {
          buildChart(title: ChartContent.processMouseEvent.rawValue, dataProperty:barChartDataProperties[.processMouseEvent]!)
          buildChart(title: ChartContent.processKeyEvent.rawValue, dataProperty:barChartDataProperties[.processKeyEvent]!)
          buildChart(title: ChartContent.processTextEvent.rawValue, dataProperty:barChartDataProperties[.processTextEvent]!)
        }

        Container().with(classes: ["chart-group"]).with(styleProperties: { _ in
          (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
        }).withContent {
          buildChart(title: ChartContent.tick.rawValue, dataProperty: barChartDataProperties[.tick]!)
          buildChart(title: ChartContent.build.rawValue, dataProperty: barChartDataProperties[.build]!)
          buildChart(title: ChartContent.updateChildren.rawValue, dataProperty: barChartDataProperties[.updateChildren]!)
          buildChart(title: ChartContent.resolveMatchedStyles.rawValue, dataProperty: barChartDataProperties[.resolveMatchedStyles]!)
          buildChart(title: ChartContent.resolveStyleProperties.rawValue, dataProperty: barChartDataProperties[.resolveStyleProperties]!)
          buildChart(title: ChartContent.layout.rawValue, dataProperty: barChartDataProperties[.layout]!)
          buildChart(title: ChartContent.updateCumulatedValues.rawValue, dataProperty: barChartDataProperties[.updateCumulatedValues]!)
        }

        buildChart(title: ChartContent.draw.rawValue, dataProperty: barChartDataProperties[.draw]!).with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.margin, Insets(bottom: 16))
        })
      }
    }

    func buildChart(title: String, dataProperty: MutableProperty<BarChart.Data>) -> Widget {
      Container().with(styleProperties: { _ in
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
      }).withContent {
        Text(title).with(classes: ["chart-title"])

        BarChart(dataProperty).with(classes: ["chart"])
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

      for (chartContent, property) in barChartDataProperties {
        property.value = updatedBarChartData[chartContent]!
      }
    }

    override public var style: Style {
      Style("&") {
        Style(".chart-group") {
          (SimpleLinearLayout.ChildKeys.margin, Insets(right: 16))
        }

        Style(".chart-title") {
          ($0.fontWeight, FontWeight.bold)
        }

        Style(".chart") {
          (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
          ($0.height, 200)
          ($0.width, 400)
          (SimpleLinearLayout.ChildKeys.margin, Insets(bottom: 16))
        }
      }
    }

    enum ChartContent: String, CaseIterable {
      case processMouseEvent, processKeyEvent, processTextEvent, tick, build, updateChildren, resolveMatchedStyles, resolveStyleProperties, layout, updateCumulatedValues, draw
    }
  }
}