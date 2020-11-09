import CustomGraphicsMath
import VisualAppBase

// TODO: maybe rename to BuildableSingleChildWidget and create another SingleChildWidget as Basis for button?... maybe can simply use Widget for this
open class SingleChildWidget: Widget {
  open var child: Widget {
    children[0]
  }

  private var nextTickRebuiltScheduled: Bool = false

  override open func performBuild() {
    children = [buildChild()]
  }

  open func buildChild() -> Widget {
    fatalError("buildChild() not implemented.")
  }

  open func invalidateChild() {
    invalidateBuild()
    /*if !mounted || destroyed {
      return
    }

    if !nextTickRebuiltScheduled {
      nextTickRebuiltScheduled = true
      nextTick { [weak self] _ in
        if let self = self {
          self.child = self.buildChild()
          self.replaceChildren(with: [self.child])
          self.nextTickRebuiltScheduled = false
        }
      }
    }
    // TODO: should there be an invalidateChildren() / invalidateBuild on Widget in general
    // and the widgets be rebuilt later, and in a way, that only the topmost ones are rebuilt? 

    // TODO: should the rest of flag functions also be fired in on click?

    invalidateBoxConfig()
    invalidateLayout()
    invalidateRenderState()*/
  }

  open func withChildInvalidation(block: () -> Void) {
    block()
    invalidateChild()
  }

  override open func getBoxConfig() -> BoxConfig {
    return child.boxConfig
  }

  override open func performLayout(constraints: BoxConstraints) -> DSize2 {
    child.layout(constraints: constraints)
    return constraints.constrain(child.bounds.size)
  }

  override open func renderContent() -> RenderObject? {
    return child.render()
  }
}
