import GfxMath

public class Container: ContentfulWidget, SlotAcceptingWidget, StylableWidget {
  public static let defaultSlot = Slot(key: "default", data: Void.self)
  var defaultSlotManager = SlotContentManager(Container.defaultSlot)
  public var defaultNoDataSlotContentManager: SlotContentManager<Void>? {
    defaultSlotManager
  }

  override public var content: ExpDirectContent {
    defaultSlotManager()
  }

  override public var contentChildren: [Widget] {
    didSet {
      updateLayoutInstance()
    }
  }

  @FromStyle(key: StyleKeys.layout)
  private var layoutType: Layout.Type = SimpleLinearLayout.self
  private var layoutInstance: Layout?

  private var childrenLayoutPropertiesHandlerRemovers: [() -> ()] = []

  override public var supportedStyleProperties: StylePropertySupportDefinitions {
    layoutInstance?.parentPropertySupportDefinitions ?? []
  }

  override public init() {
      super.init()

      _ = stylePropertiesResolver.onResolvedPropertyValuesChanged { [unowned self] in
        let oldLayoutType = $0.old[StyleKeys.layout.asString] as? Layout.Type
        let newLayoutType = $0.new[StyleKeys.layout.asString] as? Layout.Type

        if (oldLayoutType != nil && newLayoutType != nil && ObjectIdentifier(oldLayoutType!) != ObjectIdentifier(newLayoutType!)) ||
          (oldLayoutType == nil && newLayoutType != nil) || (oldLayoutType != nil && newLayoutType == nil) {
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
    stylePropertiesResolver.propertySupportDefinitions = mergedSupportedStyleProperties
    stylePropertiesResolver.resolve()

    if layoutInstance!.childPropertySupportDefinitions.count > 0 {
      for child in contentChildren {
        child.supportedParentStyleProperties["layout"] = layoutInstance!.childPropertySupportDefinitions
        child.stylePropertiesResolver.propertySupportDefinitions = child.mergedSupportedStyleProperties
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
    //max(constraints.minSize, layoutInstance!.layout(constraints: constraints))
    let accumulatedSize = layoutInstance!.layout(constraints: constraints)
    //jlet boxConfigBoxConstraints = 
    //return BoxConstraints(minSize: )
    return accumulatedSize
  }

  public enum StyleKeys: String, StyleKey, DefaultStyleKeys {
    case layout
  }
}