import GfxMath
import VisualAppBase

extension DeveloperTools {
  public class WidgetPropertiesView: ComposedWidget {
    @Inject
    var store: DeveloperTools.Store

    override public func performBuild() {
      rootChild = Container { [unowned self] in
        ReactiveContent(store.$state) {
          if let inspectedWidget = store.state.inspectedWidget {
            Container(styleProperties: { _ in
              (SimpleLinearLayout.ChildKeys.grow, 1.0)
              (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
            }) {
              Text(inspectedWidget.name).with(classes: ["widget-name"])

              Text("tree path").with(classes: ["section-heading"])

              Text(String(describing: inspectedWidget.treePath))

              buildResolvedStyleProperties(inspectedWidget)

              buildStylePropertyDefinitions(inspectedWidget)
            }
          } else {
            Space(.zero)
          }
        }
      }
    }

    public func buildStylePropertyDefinitions(_ inspectedWidget: Widget) -> [Widget] {
      [
        Text("style property definitions").with(classes: ["section-heading"])
      ] +
      inspectedWidget.mergedSupportedStyleProperties.flatMap {
        buildStylePropertyDefinition($0, inspectedWidget)
      }
    }

    public func buildStylePropertyDefinition(_ definition: StylePropertySupportDefinition, _ inspectedWidget: Widget) -> [Widget] {
      [
        Container(styleProperties: { _ in
          (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
        }) {
          Text(definition.key.asString).with(classes: ["style-key"])

          Container {
            Text("default:")
            
            Text(String(describing: definition.defaultValue))
          }
        }
      ]
    }

    public func buildResolvedStyleProperties(_ inspectedWidget: Widget) -> [Widget] {
      [Text("resolved style properties").with(classes: ["section-heading"])] +

      inspectedWidget.mergedSupportedStyleProperties.flatMap {
        buildResolvedStyleProperty($0.key, inspectedWidget)
      }
    }

    public func buildResolvedStyleProperty(_ key: StyleKey, _ inspectedWidget: Widget) -> [Widget] {
      [
        Container {
          Text(key.asString + ":").with(classes: ["style-key"])

          Text(String(describing: inspectedWidget.stylePropertyValue(key)))
        }
      ]
    }

    override public func buildStyle() -> Style {
      Style("&") {
        ($0.background, Color.white)
        ($0.padding, Insets(all: 16))

        Style(".widget-name") {
          ($0.fontSize, 20.0)
          ($0.fontWeight, FontWeight.bold)
        }

        Style(".section-heading") {
          ($0.fontSize, 16.0)
          ($0.fontWeight, FontWeight.bold)
        }

        Style(".style-key") {
          ($0.fontWeight, FontWeight.bold)
        }
      }
    }
  }
}