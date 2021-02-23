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
          buildChart(title: ChartContent.tick.rawValue, dataProperty: barChartDataProperties[.tick]!)
          buildChart(title: ChartContent.build.rawValue, dataProperty: barChartDataProperties[.build]!)
          buildChart(title: ChartContent.updateChildren.rawValue, dataProperty: barChartDataProperties[.updateChildren]!)
          buildChart(title: ChartContent.resolveStyles.rawValue, dataProperty: barChartDataProperties[.resolveStyles]!)
          buildChart(title: ChartContent.updateBoxConfig.rawValue, dataProperty: barChartDataProperties[.updateBoxConfig]!)
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
        case let .tick(tickData):
          updatedBarChartData[.tick]!.append((label: "wow", tickData.duration))

          updatedBarChartData[.build]!.append((label: "wow", tickData.operations[.build]!.duration))
          updatedBarChartData[.updateChildren]!.append((label: "wow", tickData.operations[.updateChildren]!.duration))
          updatedBarChartData[.resolveStyles]!.append((label: "wow", tickData.operations[.resolveStyles]!.duration))
          updatedBarChartData[.updateBoxConfig]!.append((label: "wow", tickData.operations[.updateBoxConfig]!.duration))
          updatedBarChartData[.layout]!.append((label: "wow", tickData.operations[.layout]!.duration))
          updatedBarChartData[.updateCumulatedValues]!.append((label: "wow", tickData.operations[.updateCumulatedValues]!.duration))

        case let .draw(drawData):
          updatedBarChartData[.draw]!.append((label: "draw", value: drawData.duration))
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
          (SimpleLinearLayout.ChildKeys.margin, Insets(bottom: 16))
        }
      }
    }

    enum ChartContent: String, CaseIterable {
      case tick, build, updateChildren, resolveStyles, updateBoxConfig, layout, updateCumulatedValues, draw
    }
  }
}