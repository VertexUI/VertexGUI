import Foundation

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
    var removedChildren = widget.previousChildren

    var anyChildChanged = false
    for (index, child) in widget.children.enumerated() {
      removedChildren.removeAll { $0 === child }

      if child.parent as? Widget !== widget {
        anyChildChanged = true
        mount(widget: child, parent: widget, treePath: widget.treePath/index)
        setupChildParentInfluence(parent: widget, child: child)
        if !child.built {
          buildSubTree(rootWidget: child)
        }
      } else {
        child.treePath = widget.treePath/index
      }
    }

    for child in removedChildren {
      child.destroy()
    }

    if anyChildChanged {
      widget.invalidateLayout()
      widget.invalidateCumulatedValues()
    }

    widget.previousChildren = widget.children
  }

  public func mount(widget: Widget, parent: Parent, treePath: TreePath) {
    widget.context = widgetContext 
    widget.setupContext()

    widget.lifecycleBus = widgetLifecycleBus
    
    widget.parent = parent

    widget.treePath = treePath

    // TODO: maybe integrate the dependency resolution logic into WidgetTreeManager
    dependencyManager.resolveDependencies(on: widget)

    widget.onDependenciesInjected.invokeHandlers(())

    widget.mounted = true

    widget.onMounted.invokeHandlers(Void())

    widget.resolveStyleProperties()

    /*build()

    built = true

    onBuilt.invokeHandlers(Void())*/
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

    widget.previousChildren = widget.children

    widget.buildInvalid = false
    widget.built = true

    widget.onBuilt.invokeHandlers(Void())

    widget.invalidateMatchedStyles()
    widget.invalidateLayout()
  }

  public func mountChildren(of widget: Widget) {
    for (index, child) in widget.children.enumerated() {
      mount(widget: child, parent: widget, treePath: widget.treePath/index)
      setupChildParentInfluence(parent: widget, child: child)
    }
  }

  func setupChildParentInfluence(parent: Widget, child: Widget) {
    if child.mounted && !child.destroyed {
      let cancellable = child.onSizeChanged { [unowned parent] _ in
        // TODO: maybe need special relayout flag / function
        if parent.layouted && !parent.layouting {
            parent.invalidateLayout()
        }
      }

      _ = parent.onDestroy {
        cancellable.cancel()
      }
    } else {
      print("warning: tried to setup child to parent effects, but child was not yet mounted or already destroyed, parent: \(parent), child: \(child)")
    }
  }
}