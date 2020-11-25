import GfxMath

extension Flex {
  internal class UniversalStrategy: LayoutStrategy {
    private var lines: [Line] = []

    override class func test(_ flex: Flex) -> Bool {
      return true
    }

    override func layout(constraints: BoxConstraints) -> DSize2 {
      lines = [
        Line(crossAxisStart: 0)
      ]

      var needSecondsPass = false
      var mainAxisSize = constraints.minSize[mainAxisVectorIndex]
      var mainAxisPosition = 0.0

      for item in items {
        let crossAlignment = item.crossAlignment ?? self.crossAlignment

        if !needSecondsPass {
          needSecondsPass =
            crossAlignment == .Center || crossAlignment == .End || crossAlignment == .Stretch
            || item.grow > 0
        }

        let content = item.content
        let contentBoxConfig = content.boxConfig
        let freeMainAxisSpace = constraints.maxSize[mainAxisVectorIndex] - mainAxisPosition
        let freeCrossAxisSpace =
          constraints.maxSize[crossAxisVectorIndex] - lines.last!.crossAxisStart
        var contentConstraints = BoxConstraints(
          minSize: .zero,
          maxSize: .infinity
        )

        switch orientation {
        case .Row:
          contentConstraints.maxSize = DSize2(freeMainAxisSpace, freeCrossAxisSpace)
        case .Column:
          contentConstraints.maxSize = DSize2(freeCrossAxisSpace, freeMainAxisSpace)
        }

        var preferredMainAxisSize = contentBoxConfig.preferredSize[mainAxisVectorIndex]
        var minMainAxisSize = contentBoxConfig.minSize[mainAxisVectorIndex]

        var explicitMainAxisSizeValue: Double? = nil
        if let explicitMainAxisSize = item.getMainAxisSize(orientation) {
          switch explicitMainAxisSize {
          case let .Pixels(value):
            explicitMainAxisSizeValue = value
          case let .Percent(value):
            explicitMainAxisSizeValue = constraints.maxSize[mainAxisVectorIndex] * value / 100
          }

          contentConstraints.maxSize[mainAxisVectorIndex] = explicitMainAxisSizeValue!

          if explicitMainAxisSizeValue!.isFinite {
            preferredMainAxisSize = explicitMainAxisSizeValue!
            contentConstraints.minSize[mainAxisVectorIndex] = explicitMainAxisSizeValue!
          }
        }

        mainAxisPosition += item.getMainAxisStartMargin(orientation)

        // + 1 at the end to account for floating point precision errors
        if wrap
          && mainAxisPosition + preferredMainAxisSize >= constraints.maxSize[mainAxisVectorIndex] + 1
        {
          // TODO: maybe only do this if shrink is set to some value > 0
          if contentBoxConfig.minSize[mainAxisVectorIndex] > freeMainAxisSpace {
            mainAxisPosition = item.getMainAxisStartMargin(orientation)

            if explicitMainAxisSizeValue == nil {
              contentConstraints.maxSize[mainAxisVectorIndex] =
                constraints.maxSize[mainAxisVectorIndex]
            }

            contentConstraints.maxSize[crossAxisVectorIndex] =
              constraints.maxSize[crossAxisVectorIndex] - lines.last!.crossAxisStart
              - lines.last!.size[crossAxisVectorIndex]

            lines.append(
              Line(
                crossAxisStart: lines.last!.crossAxisStart + lines.last!.size[crossAxisVectorIndex]))
          }
        } else if !wrap && contentConstraints.maxSize[mainAxisVectorIndex] < minMainAxisSize {
          contentConstraints.maxSize[mainAxisVectorIndex] = minMainAxisSize
          // need a second pass now because the current line can now be bigger than the Flex can be
          // so in second pass whether some items can be shrunk again
          needSecondsPass = true
        }

        if item.grow > 0 {
          // this is currently a hack to avoid the child skipping layouting
          // when the current constraints equal the past constraints
          // if not doing this, the child will simply return it's current size
          // since nothing has changed
          // but since the child's size was grown, it should be recalculated because
          // other items might have changed
          // there is probably a more clever / optimized way to do this
          content.previousConstraints = nil
        }
        
        content.layout(constraints: contentConstraints)
        content.position[mainAxisVectorIndex] = mainAxisPosition
        content.position[crossAxisVectorIndex] =
          lines.last!.crossAxisStart + item.getCrossAxisStartMargin(orientation)

        mainAxisPosition +=
          content.bounds.size[mainAxisVectorIndex] + item.getMainAxisEndMargin(orientation)

        lines[lines.count - 1].totalGrow += item.grow
        lines[lines.count - 1].totalShrink += item.shrink
        lines[lines.count - 1].items.append(item)
        lines[lines.count - 1].size[mainAxisVectorIndex] = mainAxisPosition

        let marginedCrossAxisItemSize =
          content.bounds.size[crossAxisVectorIndex] + item.getCrossAxisStartMargin(orientation)
          + item.getCrossAxisEndMargin(orientation)
        if marginedCrossAxisItemSize > lines.last!.size[crossAxisVectorIndex] {
          lines[lines.count - 1].size[crossAxisVectorIndex] = marginedCrossAxisItemSize
        }

        if mainAxisPosition > mainAxisSize {
          mainAxisSize = mainAxisPosition
        }

        if wrap && constraints.maxSize[mainAxisVectorIndex] < mainAxisPosition {
          mainAxisPosition = 0
          lines.append(
            Line(crossAxisStart: lines.last!.crossAxisStart + lines.last!.size[crossAxisVectorIndex]))
        } else {
          mainAxisPosition += spacing
        }
      }

      // some lines might overflow the constraints, which is taken care of in the second pass
      // however limit the overall mainAxisSize to the constraints' size
      mainAxisSize = min(constraints.maxSize[mainAxisVectorIndex], mainAxisSize)

      if needSecondsPass {
        // second pass through all lines
        for (lineIndex, var line) in lines.enumerated() {
          // if the flex got a min size constraints in cross direction,
          // every line should have that size
          if line.size[crossAxisVectorIndex] < constraints.minSize[crossAxisVectorIndex] {
            line.size[crossAxisVectorIndex] = constraints.minSize[crossAxisVectorIndex]
          }

          // based on the line size, the flex constraints and the items
          // properties such as grow, shrink, stretch update the constraints for each item
          var updatedItemConstraints: [BoxConstraints] = []
          // the indices of the items that need to be layouted with updated constraints again
          var relayoutItemIndices: Set<Int> = []

          // first update the items in the cross axis direction
          for (index, item) in line.items.enumerated() {
            let content = item.content
            
            var newConstraints = BoxConstraints(
              minSize: content.bounds.size,
              maxSize: content.bounds.size
            )
            var relayout = false

            let crossAlignment = item.crossAlignment ?? self.crossAlignment

            switch crossAlignment {
            case .Center:
              let marginedCrossAxisItemSize =
                content.bounds.size[crossAxisVectorIndex] + item.getCrossAxisStartMargin(orientation)
                + item.getCrossAxisEndMargin(orientation)
              content.position[crossAxisVectorIndex] =
                line.crossAxisStart + line.size[crossAxisVectorIndex] / 2 - marginedCrossAxisItemSize
                / 2

            case .Stretch:
              newConstraints.minSize[crossAxisVectorIndex] = line.size[crossAxisVectorIndex]
              newConstraints.maxSize[crossAxisVectorIndex] = line.size[crossAxisVectorIndex]
              relayout = true

            default:
              break
            }

            updatedItemConstraints.append(newConstraints)

            if relayout {
              relayoutItemIndices.insert(index)
            }
          }


          // now update the items in the main axis direction
          var mainAxisPosition = 0.0
          
          if line.size[mainAxisVectorIndex] > constraints.maxSize[mainAxisVectorIndex] {
            // if the line is bigger in main axis than the whole flex can be

            var mainAxisShrinkSpace = line.size[mainAxisVectorIndex] - constraints.maxSize[mainAxisVectorIndex]
            var mainAxisTotalShrink = line.totalShrink
            // space that needs to be additionally shrunk by items that have not yet hit their box config min size
            var tmpMainAxisShrinkSpace = 0.0
            var tmpTotalShrink = 0.0

            var maximallyShrunkItemIndices: Set<Int> = []

            var itemIndex = 0
            var needAnotherShrinkPass = false
            var shrinkPassIndex = 0
            while itemIndex < line.items.count {
              let item = line.items[itemIndex]
              let content = item.content

              mainAxisPosition += item.getMainAxisStartMargin(orientation)
              content.position[mainAxisVectorIndex] = mainAxisPosition
              
              var newConstraints = updatedItemConstraints[itemIndex]
              var relayout = relayoutItemIndices.contains(itemIndex)

              if item.shrink > 0 && !maximallyShrunkItemIndices.contains(itemIndex) {
                var itemShrinkSpace = mainAxisShrinkSpace * (item.shrink / mainAxisTotalShrink)
          
                var shrunkenItemSize = content.bounds.size[mainAxisVectorIndex] - itemShrinkSpace

                var constrainedShrunkenItemSize = max(shrunkenItemSize, content.boxConfig.minSize[mainAxisVectorIndex])

                if constrainedShrunkenItemSize > shrunkenItemSize {
                  tmpMainAxisShrinkSpace += constrainedShrunkenItemSize - shrunkenItemSize
                  maximallyShrunkItemIndices.insert(itemIndex)
                  needAnotherShrinkPass = true
                } else {
                  tmpTotalShrink += item.shrink
                }

                newConstraints.minSize[mainAxisVectorIndex] = constrainedShrunkenItemSize
                newConstraints.maxSize[mainAxisVectorIndex] = constrainedShrunkenItemSize

                relayout = true
              }

              if relayout {
                // hack to preserve previous constraints on the child 
                // (the new constraints are only constraining to one exact size
                // and do not reflect the real min/max width/height)
                let previousConstraints = content.previousConstraints
                content.layout(constraints: newConstraints)
                content.previousConstraints = previousConstraints
                relayoutItemIndices.remove(itemIndex)
              }

              mainAxisPosition +=
                content.bounds.size[mainAxisVectorIndex] + item.getMainAxisEndMargin(orientation)

              if content.bounds.size[crossAxisVectorIndex] > line.size[crossAxisVectorIndex] {
                line.size[crossAxisVectorIndex] = content.bounds.size[crossAxisVectorIndex]
              }

              mainAxisPosition += spacing

              itemIndex += 1

              if itemIndex == line.items.count && shrinkPassIndex < 5 {
                if needAnotherShrinkPass {
                  itemIndex = 0
                  shrinkPassIndex += 1
                  mainAxisPosition = 0
                  mainAxisShrinkSpace = tmpMainAxisShrinkSpace
                  mainAxisTotalShrink = tmpTotalShrink
                  tmpMainAxisShrinkSpace = 0
                  tmpTotalShrink = 0
                  needAnotherShrinkPass = false
                }
              }
            }
          } else if (line.size[mainAxisVectorIndex] < mainAxisSize) {
            // if the line's main axis is shorter than the whole flex, can grow some items
            
            let mainAxisGrowSpace = mainAxisSize - line.size[mainAxisVectorIndex]

            if lineIndex > 0 {
              line.crossAxisStart =
                lines[lineIndex - 1].crossAxisStart + lines[lineIndex - 1].size[crossAxisVectorIndex]
            }

            // pass through items in line, grow rest free space, apply CrossAlignment
            for (index, item) in line.items.enumerated() {
              let content = item.content

              var newConstraints = updatedItemConstraints[index]
              
              var relayout = relayoutItemIndices.contains(index)

              mainAxisPosition += item.getMainAxisStartMargin(orientation)
              content.position[mainAxisVectorIndex] = mainAxisPosition

              if item.grow > 0 {
                let itemGrow = mainAxisGrowSpace * (item.grow / line.totalGrow)
                newConstraints.minSize[mainAxisVectorIndex] =
                  content.bounds.size[mainAxisVectorIndex] + itemGrow
                newConstraints.maxSize[mainAxisVectorIndex] =
                  content.bounds.size[mainAxisVectorIndex] + itemGrow
                relayout = true
              }

              if relayout {
                // saving and storing the previousConstraints is a hack currently to
                // let the content change it's size according to the real constraints
                // it obtained above,
                // TODO: might introduce a separate property on Widget like: parentConstraints / mainConstraints
                // which can be used by the widget itself to determine how much it can grow on content change
                let previousConstraints = content.previousConstraints
                content.layout(constraints: newConstraints)
                content.previousConstraints = previousConstraints
                relayoutItemIndices.remove(index)
              }

              mainAxisPosition +=
                content.bounds.size[mainAxisVectorIndex] + item.getMainAxisEndMargin(orientation)

              if content.bounds.size[crossAxisVectorIndex] > line.size[crossAxisVectorIndex] {
                line.size[crossAxisVectorIndex] = content.bounds.size[crossAxisVectorIndex]
              }

              if mainAxisPosition > line.size[mainAxisVectorIndex] {
                line.size[mainAxisVectorIndex] = mainAxisPosition
              }

              /*if mainAxisPosition > mainAxisSize {
                mainAxisSize = mainAxisPosition
              }*/

              mainAxisPosition += spacing
            }
          }

          // if the items were not relayouted because no change in the main axis was necessary
          // (this might for example happen for the longest line)
          // need to run this, to make sure the cross axis is updated
          for index in relayoutItemIndices {
            let content = items[index].content
            let newConstraints = updatedItemConstraints[index]

            let previousConstraints = content.previousConstraints
            content.layout(constraints: newConstraints)
            content.previousConstraints = previousConstraints
    
            if content.bounds.size[crossAxisVectorIndex] > line.size[crossAxisVectorIndex] {
              line.size[crossAxisVectorIndex] = content.bounds.size[crossAxisVectorIndex]
            }

            relayoutItemIndices.remove(index)
          }
          
          lines[lineIndex] = line
        }
      }

      switch orientation {
      case .Row:
        return constraints.constrain(
          DSize2(mainAxisSize, lines.last!.crossAxisStart + lines.last!.size[crossAxisVectorIndex]))
      case .Column:
        return constraints.constrain(
          DSize2(lines.last!.crossAxisStart + lines.last!.size[crossAxisVectorIndex], mainAxisSize))
      }
    }
  }
}