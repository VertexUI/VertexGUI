import GfxMath
import VisualAppBase

extension DeveloperTools {
  public class WidgetPropertiesView: ContentfulWidget {
    @Inject
    var store: DeveloperTools.Store

    @ExpDirectContentBuilder override public var content: ExpDirectContent {
      Container().withContent { [unowned self] in

        Dynamic(store.$state.inspectedWidget) {

          if let inspectedWidget = store.state.inspectedWidget {

            Container().experimentalWith(styleProperties: {
              (\.$grow, 1.0)
              (\.$direction, SimpleLinearLayout.Direction.column)
            }).withContent {

              Text(inspectedWidget.name).with(classes: ["widget-name"])

              Container().with(classes: ["section"]).withContent {
                Text("tree path").with(classes: ["section-heading"])
                Text(String(describing: inspectedWidget.treePath))
              }

              buildStyleProperties(for: inspectedWidget)
              buildMatchedStyles(for: inspectedWidget)
            }
          } else {
            Space(.zero)
          }
        }
      }
    }

    func buildStyleProperties(for widget: Widget) -> Widget {
      var propertyRepresentations = [Widget]()

      let mirror = Mirror(reflecting: widget)
      for child in mirror.allChildren {
        if type(of: child.value) is ExperimentalAnyStylePropertyProtocol.Type, let property = child.value as? ExperimentalAnyStylePropertyProtocol {
          propertyRepresentations.append(buildStyleProperty(child.label ?? "", property))
        }
      }

      return Container().with(classes: ["section"]).experimentalWith(styleProperties: {
        (\.$direction, .column)
      }).withContent {
        Text("style properties").with(classes: ["section-heading"])

        propertyRepresentations
      }
    }

    func buildStyleProperty(_ name: String, _ property: ExperimentalAnyStylePropertyProtocol) -> Widget {
      Text(name).with(classes: ["key"])
    }

    func buildMatchedStyles(for widget: Widget) -> Widget {
      Container().with(classes: ["section"]).withContent {
        Text("matched styles").with(classes: ["section-heading"])

        widget.experimentalMatchedStyles.map {
          buildStyleInfo($0)
        }
      }
    }

    func buildStyleInfo(_ style: Experimental.Style) -> Widget {
      Container().with(classes: ["style-info"]).withContent {
        Text("style: \(style.selector)").with(classes: ["style-identifier"])

        Container().with(classes: ["key-value-item"]).withContent {
          Text("tree path").with(classes: ["key"])
          Text("\(style.treePath)")
        }

        style.propertyValueDefinitions.map { definition in
          Container().with(classes: ["key-value-item"]).withContent {
            Text("\(definition.keyPath)").with(classes: ["key"])
            Text("\(String(describing: definition.value))")
          }
        }
      }
    }

    override public var experimentalStyle: Experimental.Style {
      Experimental.Style("&") {
        (\.$background, .white)
        (\.$foreground, .black)
        (\.$padding, Insets(all: 16))
      } nested: {
        Experimental.Style(".widget-name") {
          (\.$fontSize, 20.0)
          (\.$fontWeight, .bold)
          (\.$margin, Insets(bottom: 16))
        }

        Experimental.Style(".section", Container.self) {
          (\.$margin, Insets(bottom: 16))
          (\.$direction, .column)
        }

        Experimental.Style(".section-heading") {
          (\.$fontSize, 16.0)
          (\.$fontWeight, FontWeight.bold)
          (\.$margin, Insets(bottom: 8))
        }

        Experimental.Style(".key-value-item", Container.self) {
          (\.$margin, Insets(bottom: 8))
          (\.$direction, .row)
        }

        Experimental.Style(".key") {
          (\.$fontWeight, .bold)
        }

        Experimental.Style(".style-info", Container.self) {
          (\.$direction, .column)
          (\.$margin, Insets(bottom: 16))
        }

        Experimental.Style(".style-identifier") {
          (\.$fontWeight, .bold)
          (\.$fontSize, 16.0)
          (\.$margin, Insets(bottom: 8))
        }
      }
    }
  }
}