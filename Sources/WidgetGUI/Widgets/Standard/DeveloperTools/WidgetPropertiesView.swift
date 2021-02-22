import GfxMath
import VisualAppBase

extension DeveloperTools {
  public class WidgetPropertiesView: ComposedWidget {
    @Inject
    var store: DeveloperTools.Store

    override public func performBuild() {
      rootChild = Container().withContent { [unowned self] in
        Dynamic(store.$state) {
          if let inspectedWidget = store.state.inspectedWidget {
            Container().with(styleProperties: { _ in
              (SimpleLinearLayout.ChildKeys.grow, 1.0)
              (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
            }).withContent {

              Text(inspectedWidget.name).with(classes: ["widget-name"])

              Container().with(classes: ["section"]).withContent {
                Text("tree path").with(classes: ["section-heading"])
                Text(String(describing: inspectedWidget.treePath))
              }

              buildResolvedStyleProperties(inspectedWidget)

              buildStylePropertyDefinitions(inspectedWidget)
            }
          } else {
            Space(.zero)
          }
        }
      }
    }

    public func buildStylePropertyDefinitions(_ inspectedWidget: Widget) -> Widget {
      Container().with(classes: ["section"]).withContent {
        Text("style property definitions").with(classes: ["section-heading"])

        inspectedWidget.mergedSupportedStyleProperties.flatMap {
          buildStylePropertyDefinition($0, inspectedWidget)
        }
      }
    }

    public func buildStylePropertyDefinition(_ definition: StylePropertySupportDefinition, _ inspectedWidget: Widget) -> Widget {
      Container().with(classes: ["key-value-item"]).withContent {
        Text(definition.key.asString).with(classes: ["style-key"])

        Container().withContent {
          Text("default:")
          
          Text(String(describing: definition.defaultValue))
        }
      }
    }

    public func buildResolvedStyleProperties(_ inspectedWidget: Widget) -> Widget {
      Container().with(classes: ["section"]).withContent {
        Text("resolved style properties").with(classes: ["section-heading"])

        inspectedWidget.mergedSupportedStyleProperties.flatMap {
          buildResolvedStyleProperty($0.key, inspectedWidget)
        }
      }
    }

    public func buildResolvedStyleProperty(_ key: StyleKey, _ inspectedWidget: Widget) -> Widget {
      Container().with(classes: ["key-value-item"]).withContent { _ in
        Text(key.asString + ":").with(classes: ["style-key"])

        Text(String(describing: inspectedWidget.stylePropertyValue(key)))
      }
    }

    override public var style: Style {
      Style("&") {
        ($0.background, Color.white)
        ($0.foreground, Color.black)
        ($0.padding, Insets(all: 16))

        Style(".widget-name") {
          ($0.fontSize, 20.0)
          ($0.fontWeight, FontWeight.bold)
          (SimpleLinearLayout.ChildKeys.margin, Insets(bottom: 16))
        }

        Style(".section") {
          (SimpleLinearLayout.ChildKeys.margin, Insets(bottom: 16))
          (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
        }

        Style(".section-heading") {
          ($0.fontSize, 16.0)
          ($0.fontWeight, FontWeight.bold)
          (SimpleLinearLayout.ChildKeys.margin, Insets(bottom: 8))
        }

        Style(".key-value-item") {
          (SimpleLinearLayout.ChildKeys.margin, Insets(bottom: 8))
          (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.row)
        }

        Style(".style-key") {
          ($0.fontWeight, FontWeight.bold)
        }
      }
    }
  }
}