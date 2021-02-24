import Foundation
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

      if let specificStyle = widget.specificWidgetStyle {
        let newPath = widget.treePath/widget.children.count
        if newPath != specificStyle.treePath {
          specificStyle.treePath = newPath
          // TODO: maybe instead have something like widget.notifySpecificStyleChanged() / widget.notifyProvidedStylesChanged() ...
          child.invalidateMatchedStyles()
        }
      }
    }

    for child in removedChildren {
      child.destroy()
    }

    if anyChildChanged {
      widget.invalidateBoxConfig()
      widget.invalidateLayout()
    }

    widget.previousChildren = widget.children
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

    /*build()

    built = true

    onBuilt.invokeHandlers(Void())*/

    widget.context.queueLifecycleMethodInvocation(.resolveCumulatedValues, target: widget, sender: widget, reason: .undefined)
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

    if let style = widget.style {
      widget.specificWidgetStyle = style
      widget.specificWidgetStyle!.treePath = widget.treePath/widget.children.count
    }

    widget.invalidateMatchedStyles()
    widget.invalidateBoxConfig()
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
      _ = parent.onDestroy(child.onBoxConfigChanged { [unowned parent] _ in
        parent.invalidateBoxConfig()
        // note that the layout pass should start from the topmost parent, for which the
        // box config did not change (or the root widget if all box configs changed)
        // this is achieved by first resolving all box config invalidations in on tick
        // and only after that resolving all the layout requests generated
        // starting from the topmost widget
        parent.invalidateLayout()
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
    } else {
      print("warning: tried to setup child to parent effects, but child was not yet mounted or already destroyed, parent: \(parent), child: \(child)")
    }
  }
}