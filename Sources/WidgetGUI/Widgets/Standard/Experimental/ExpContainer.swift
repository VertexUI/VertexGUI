import GfxMath

extension Experimental {
  public class Container: Widget, ExperimentalStylableWidget {
    private let content: ExperimentalMultiChildContentBuilder.Content

    @FromStyle(key: StyleKeys.layout)
    private var layoutType: Layout.Type = SimpleLinearLayout.self
    private var layoutInstance: Layout?

    private var childrenLayoutPropertiesHandlerRemovers: [() -> ()] = []

    override public var experimentalSupportedStyleProperties: Experimental.StylePropertySupportDefinitions {
      layoutInstance?.parentPropertySupportDefinitions ?? []
    }

    public init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> Experimental.StyleProperties = { _ in [] },
      @ExperimentalMultiChildContentBuilder content contentBuilder: @escaping () -> ExperimentalMultiChildContentBuilder.Content) {
        content = contentBuilder()
        super.init()

        self.contentChildren = content.widgets
        _ = content.onChanged { [unowned self] in 
          contentChildren = content.widgets
          requestRemountChildren()
          updateLayoutInstance()
        }

        self.experimentalProvidedStyles.append(contentsOf: content.styles)
        if let classes = classes {
          self.classes = classes
        }
        self.with(stylePropertiesBuilder(StyleKeys.self))

        _ = stylePropertiesResolver.onResolvedPropertyValuesChanged { [unowned self] in
          let oldLayoutProperty = $0.old[StyleKeys.layout.asString]
          let newLayoutProperty = $0.new[StyleKeys.layout.asString]

          if let oldLayoutType = oldLayoutProperty as? Layout.Type,
            let newLayoutType = newLayoutProperty as? Layout.Type,
            ObjectIdentifier(oldLayoutType) != ObjectIdentifier(newLayoutType) {
              updateLayoutInstance()
          } else {
            updateLayoutInstanceProperties()
          }
        }

        _ = onDestroy(removeChildrenLayoutPropertiesHandlers)

        updateLayoutInstance()
    }

    private func updateLayoutInstance() {
      removeChildrenLayoutPropertiesHandlers()

      layoutInstance = layoutType.init(widgets: contentChildren, layoutPropertyValues: [:])
      stylePropertiesResolver.propertySupportDefinitions = experimentalMergedSupportedStyleProperties
      stylePropertiesResolver.resolve()

      //updateLayoutInstanceProperties()

      if layoutInstance!.childPropertySupportDefinitions.count > 0 {
        for child in contentChildren {
          child.experimentalSupportedParentStyleProperties["layout"] = layoutInstance!.childPropertySupportDefinitions
          child.stylePropertiesResolver.propertySupportDefinitions = child.experimentalMergedSupportedStyleProperties
          child.stylePropertiesResolver.resolve()

          childrenLayoutPropertiesHandlerRemovers.append(child.stylePropertiesResolver.onResolvedPropertyValuesChanged { [unowned self] _ in
            invalidateLayout()
          })
        }
      }
    }

    private func updateLayoutInstanceProperties() {
      for property in layoutInstance!.parentPropertySupportDefinitions {
        layoutInstance!.layoutPropertyValues[property.key.asString] = stylePropertyValue(property.key)
      }
      if mounted && layouted {
        invalidateLayout()
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
      max(constraints.minSize, layoutInstance!.layout(constraints: constraints))
    }

    public enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case layout
    }
  }
}