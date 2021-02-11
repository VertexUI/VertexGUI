import GfxMath

extension Experimental {
  public class Container: Widget, ExperimentalStylableWidget {
    @FromStyle(key: StyleKeys.layout)
    private var layoutType: Layout.Type = AbsoluteLayout.self
    private var layoutInstance: Layout?

    private var childrenLayoutPropertiesHandlerRemovers: [() -> ()] = []

    public init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> Experimental.StyleProperties = { _ in [] },
      @MultiChildContentBuilder content contentBuilder: @escaping () -> MultiChildContentBuilder.Result) {
        let content = contentBuilder()
        super.init()

        self.contentChildren = content.childrenBuilder()

        self.experimentalProvidedStyles.append(contentsOf: content.experimentalStyles)
        if let classes = classes {
          self.classes = classes
        }
        self.with(stylePropertiesBuilder(StyleKeys.self))

        _ = $layoutType.onChanged { [unowned self] in
          if ObjectIdentifier($0.old) != ObjectIdentifier($0.new) {
            updateLayoutInstance()
          }
        }

        _ = onDestroy(removeChildrenLayoutPropertiesHandlers)

        updateLayoutInstance()
    }

    private func updateLayoutInstance() {
      removeChildrenLayoutPropertiesHandlers()

      layoutInstance = layoutType.init(widgets: contentChildren)
      if layoutInstance!.childPropertySupportDefinitions.count > 0 {
        for child in contentChildren {
          childrenLayoutPropertiesHandlerRemovers.append(child.stylePropertiesResolver.onResolvedPropertyValuesChanged { [unowned self] _ in
            invalidateLayout()
          })
        }
      }
    }

    private func removeChildrenLayoutPropertiesHandlers() {
      for remove in childrenLayoutPropertiesHandlerRemovers {
        remove()
      }
      childrenLayoutPropertiesHandlerRemovers = []
    }

    override public func getContentBoxConfig() -> BoxConfig {
      return layoutInstance!.getBoxConfig()
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      return layoutInstance!.layout(constraints: constraints)
    }

    public enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case layout
    }
  }
}