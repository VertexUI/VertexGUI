import GfxMath

class CumulatedValuesProcessor {
  var root: Root

  init(_ root: Root) {
    self.root = root
  }

  func processQueue() {
    let queue = root.widgetLifecycleManager.queues[.resolveCumulatedValues]!

    var iterator = queue.iterateSubTreeRoots()
    while let next = iterator.next() {
      resolveSubTree(rootWidget: next.target)
    }

    queue.clear()
  }

  func resolveSubTree(rootWidget: Widget) {
    var initialParents = [rootWidget]
    while let parent = initialParents.last!.parent as? Widget {
      initialParents.append(parent)
    }
    initialParents.reverse()

    var currentTransforms = [DTransform2]()
    for parent in initialParents {
      currentTransforms.append(contentsOf: getTransforms(parent))
    }

    rootWidget.cumulatedTransforms = currentTransforms

    var queuedIterations = [(rootWidget.visitChildren(), currentTransforms)]

    while queuedIterations.count > 0 {
      var (iterator, previousTransforms) = queuedIterations.removeFirst()

      while let widget = iterator.next() {
        let currentTransforms = previousTransforms + getTransforms(widget)
        widget.cumulatedTransforms = currentTransforms

        if widget.children.count > 0 {
          queuedIterations.append((widget.visitChildren(), currentTransforms))
        }
      }
    }
  }

  func getTransforms(_ widget: Widget) -> [DTransform2] {
    var transforms = [DTransform2]()
    transforms.append(.translate(widget.position))
    if !widget.unaffectedByParentScroll, let parent = widget.parent as? Widget, parent.currentScrollOffset != .zero {
      transforms.append(.translate(-parent.currentScrollOffset))
    }
    return transforms
  }
}