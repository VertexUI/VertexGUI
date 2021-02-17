import VisualAppBase

public class WidgetTreeManager {
  public var widgetContext: WidgetContext
  public var widgetLifecycleBus: WidgetBus<WidgetLifecycleMessage>
  var dependencyManager = DependencyManager()

  public init(widgetContext: WidgetContext, widgetLifecycleBus: WidgetBus<WidgetLifecycleMessage>) {
    self.widgetContext = widgetContext
    self.widgetLifecycleBus = widgetLifecycleBus
  }

  public func mountAsRoot(widget: Widget, root: Root) {
    mount(widget: widget, parent: root, treePath: [])     
  }

  public func buildSubTree(rootWidget: Widget) {
    buildChildren(of: rootWidget)
    //mountChildren(of: rootWidget)
    // TODO: implement non recursive buildSubTree method
    for child in rootWidget.children {
      buildSubTree(rootWidget: child)
    }
  }

  public func updateChildren(of widget: Widget) {
    for (index, child) in widget.children.enumerated() {
      if child.parent as? Widget !== widget {
        mount(widget: child, parent: widget, treePath: widget.treePath/index)
        setupChildParentInfluence(parent: widget, child: child)
        if !child.built {
          buildSubTree(rootWidget: child)
        }
      }
    }
  }

  public func mount(widget: Widget, parent: Parent, treePath: TreePath) {
    widget.context = widgetContext 
    widget.setupContext()

    widget.stylePropertiesResolver.propertySupportDefinitions = widget.mergedSupportedStyleProperties

    widget.lifecycleBus = widgetLifecycleBus
    
    widget.parent = parent

    widget.setupInhertiableStylePropertiesValues()

    widget.treePath = treePath

    // TODO: maybe integrate the dependency resolution logic into WidgetTreeManager
    dependencyManager.resolveDependencies(on: widget)

    widget.onDependenciesInjected.invokeHandlers(())

    widget.mounted = true

    widget.onMounted.invokeHandlers(Void())

    if let style = widget.buildStyle() {
      widget.providedStyles.insert(style, at: 0)
    }

    /*build()

    built = true

    onBuilt.invokeHandlers(Void())*/

    widget.invalidateMatchedStyles()
  }

  public func buildChildren(of widget: Widget) {
    // TODO: should probably not call destroy here as these children might be mounted somewhere else, maybe have something like unmount()
    /*for oldChild in oldChildren {
        oldChild.destroy()
    }*/

    Widget.inStyleScope(widget.createsStyleScope ? widget.id : widget.styleScope) {
      widget.performBuild()
    }

    mountChildren(of: widget)

    widget.buildInvalid = false
    widget.built = true

    widget.onBuilt.invokeHandlers(Void())

    widget.invalidateBoxConfig()
    widget.invalidateLayout()
    widget.invalidateRenderState()
  }

  public func mountChildren(of widget: Widget) {
    for (index, child) in widget.children.enumerated() {
      mount(widget: child, parent: widget, treePath: widget.treePath/index)
      setupChildParentInfluence(parent: widget, child: child)
    }
  }

  func setupChildParentInfluence(parent: Widget, child: Widget) {
    _ = parent.onDestroy(child.onBoxConfigChanged { [unowned parent, unowned child] _ in
      parent.handleChildBoxConfigChanged(child: child)
    })

    _ = parent.onDestroy(child.onSizeChanged { [unowned parent] _ in
      // TODO: maybe need special relayout flag / function
      if parent.layouted && !parent.layouting {
          parent.invalidateLayout()
      }
    })
    
    _ = child.onFocusChanged { [weak parent] in
      if let parent = parent {
          parent.focused = $0
      }
    }
  }
}