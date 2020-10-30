import CustomGraphicsMath

extension Flex {
  internal class TwoItemStrategy: LayoutStrategy {
    override class func test(_ flex: Flex) -> Bool {
      !flex.wrap && flex.items.count == 2 && flex.items[0].grow == 0 && flex.items[1].grow > 0
    }

    override func layout(constraints: BoxConstraints) -> DSize2 {
      // TODO: this algorithm doesn't implement the case that the first
      // child needs to stretch to the size of the second child
      let item1 = items[0]
      var minSize1 = DSize2.zero
      if item1.crossAlignment == .Stretch && constraints.maxSize[crossAxisVectorIndex].isFinite {
        minSize1[crossAxisVectorIndex] = constraints.maxSize[crossAxisVectorIndex]
      }
      let constraints1 = BoxConstraints(minSize: .zero, maxSize: constraints.maxSize)
      let child1 = item1.content
      child1.layout(constraints: constraints1)
      child1.position[mainAxisVectorIndex] = item1.getMainAxisStartMargin(orientation)

      let item2 = items[1]
      var minSize2 = DSize2.zero
      if item2.grow > 0 && constraints.maxSize[mainAxisVectorIndex].isFinite {
        minSize2[mainAxisVectorIndex] = constraints.maxSize[mainAxisVectorIndex] - child1.size[mainAxisVectorIndex]
      }
      if item2.crossAlignment == .Stretch && constraints.maxSize[crossAxisVectorIndex].isFinite {
        minSize2[crossAxisVectorIndex] = constraints.maxSize[crossAxisVectorIndex]
      } else if item2.crossAlignment == .Stretch {
        minSize2[crossAxisVectorIndex] = child1.size[crossAxisVectorIndex]
      }
      var maxSize2 = constraints.maxSize
      maxSize2[mainAxisVectorIndex] -= child1.size[mainAxisVectorIndex]
      let constraints2 = BoxConstraints(minSize: minSize2, maxSize: maxSize2)
      let child2 = item2.content
      child2.layout(constraints: constraints2)
      child2.position[mainAxisVectorIndex] = child1.position[mainAxisVectorIndex]
      child2.position[mainAxisVectorIndex] += child1.size[mainAxisVectorIndex]
      child2.position[mainAxisVectorIndex] += spacing
      child2.position[mainAxisVectorIndex] += item1.getMainAxisEndMargin(orientation)
      child2.position[mainAxisVectorIndex] += item2.getMainAxisStartMargin(orientation)

      var totalSize = DSize2.zero
      totalSize[mainAxisVectorIndex] = child2.position[mainAxisVectorIndex] + child2.size[mainAxisVectorIndex]
      totalSize[crossAxisVectorIndex] = max(
        child1.size[crossAxisVectorIndex], child2.size[crossAxisVectorIndex])

      // TODO: cross axis center and end alignments not yet implemented for both children

      return totalSize
    }
  }
}