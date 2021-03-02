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

    var queuedIterations = [(rootWidget.children.makeIterator(), currentTransforms)]

    while queuedIterations.count > 0 {
      var (iterator, previousTransforms) = queuedIterations.removeFirst()

      while let widget = iterator.next() {
        let currentTransforms = previousTransforms + getTransforms(widget)
        widget.cumulatedTransforms = currentTransforms

        if widget.children.count > 0 {
          // TODO: maybe scroll translation should be added here instead of by accessing parent in getTransforms
          queuedIterations.append((widget.children.makeIterator(), currentTransforms))
        }
      }
    }
  }

  func getTransforms(_ widget: Widget) -> [DTransform2] {
    var transforms = [DTransform2]()
    transforms.append(.translate(widget.layoutedPosition))
    transforms.append(contentsOf: widget.transform)
    if let parent = widget.parent as? Widget {
      if parent.padding.left != 0 || parent.padding.top != 0 {
        transforms.append(.translate(DVec2(parent.padding.left, parent.padding.top)))
      }
      if !widget.unaffectedByParentScroll, parent.currentScrollOffset != .zero {
        transforms.append(.translate(-parent.currentScrollOffset))
      }
    }
    return transforms
  }
}