public class StyleManager {
  public init() {}

  public func processTree(_ initialWidget: Widget) {
    // read and match the styles of everything down to initialWidget without applying
    var initialParents = [initialWidget]
    while let parent = initialParents.last!.parent as? Widget {
      initialParents.append(parent)
    }
    initialParents.reverse()

    var partialMatches = [PartialMatch]()

    for (index, parent) in initialParents.enumerated() {
      let (updatedPartialMatches, fullMatches) = continueMatching(previousPartialMatches: partialMatches, widget: parent)

      // the initialWidget is the first widget to actually receive matched styles
      if index == initialParents.count - 1 {
        initialWidget.experimentalMatchedStyles = fullMatches 
      }

      partialMatches = updatedPartialMatches
    }

    var queue = [QueueEntry]()
    queue.append(QueueEntry(iterator: initialWidget.children.makeIterator(), partialMatches: partialMatches))

    while queue.count > 0 {
      var entry = queue.removeFirst()

      while let widget = entry.iterator.next() {
        let (newPartialMatches, fullMatches) = continueMatching(previousPartialMatches: entry.partialMatches, widget: widget)
        widget.experimentalMatchedStyles = fullMatches
        queue.append(QueueEntry(iterator: widget.children.makeIterator(), partialMatches: newPartialMatches))
      }
    }
  }

  /**
  - Returns: a tuple of:
    - the partial matches that are to be checked on the children of widget
    - the styles matched on widget
    - the styles available to the children of widget, containing all styles that were sub styles of styles that got applied to widget
  */
  private func continueMatching(previousPartialMatches: [PartialMatch], widget: Widget) -> 
    (partialMatches: [PartialMatch], fullMatches: [Experimental.Style]) {
      var partialMatchesToCheck = previousPartialMatches

      for style in widget.experimentalMergedProvidedStyles {
        // use match index -2 to delay matching of non extending styles
        // to the children of the current widget
        partialMatchesToCheck.append(PartialMatch(
          style: style,
          matchIndex: style.selector.extendsParent ? -1 : -2,
          openScopes: [style.sourceScope]))
      }

      var fullMatches = [Experimental.Style]()
      var newPartialMatches = [PartialMatch]()

      var partialMatchIndex = 0
      while partialMatchIndex < partialMatchesToCheck.count {
        let checkPartialMatch = partialMatchesToCheck[partialMatchIndex]
        
        if checkPartialMatch.matchIndex == -2 {
          partialMatchesToCheck[partialMatchIndex] = checkPartialMatch.incremented()

        } else if checkPartialMatch.openScopes.contains(widget.styleScope) &&
          (checkPartialMatch.style.selector.partCount == 0 || checkPartialMatch.style.selector[part: checkPartialMatch.matchIndex + 1].selects(widget)) {
            
            var nextOpenScopes = checkPartialMatch.openScopes
            if checkPartialMatch.style.selector.partCount > checkPartialMatch.matchIndex + 1 &&
              checkPartialMatch.style.selector[part: checkPartialMatch.matchIndex + 1].opensScope {
                nextOpenScopes.append(widget.id)
            }

            if checkPartialMatch.style.selector.partCount - 1 > checkPartialMatch.matchIndex + 1 {
              newPartialMatches.append(checkPartialMatch.incremented(openScopes: nextOpenScopes))
            } else {
              fullMatches.append(checkPartialMatch.style)
              // the sub styles of the matched style
              // can can now match the current widget (if they extend their parent)
              // and the children as well
              partialMatchesToCheck.insert(contentsOf: checkPartialMatch.style.children.map {
                // use match index -2 to delay matching of non extending styles
                // to the children of the current widget
                PartialMatch(style: $0, matchIndex: $0.selector.extendsParent ? -1 : -2, openScopes: nextOpenScopes)
              }, at: partialMatchIndex + 1)
            }
        } else {
          // TODO: when direct parent > child syntax is there
          // (meaning no unknown number of Widgets inbetween)
          // then need to check whether the part is of this kind
          // and if yes remove the whole partial match
        }

        partialMatchIndex += 1
      }

      // styles which extend their parent, can start matching only on their direct parent
      // if the style is a root style (has no style parent) it can only start matching on the widget it came from
      // if the style is a sub style which extends it's parent, the first match can only happen after
      // the parent had a full match
      let updatedPartialMatches = (partialMatchesToCheck + newPartialMatches).filter {
        !($0.matchIndex == -1 && $0.style.selector.extendsParent)
      }

      return (partialMatches: updatedPartialMatches, fullMatches: fullMatches)
  }

  private struct QueueEntry {
    var iterator: Array<Widget>.Iterator
    let partialMatches: [PartialMatch]
  }

  private struct PartialMatch {
    let style: Experimental.Style
    let matchIndex: Int
    let openScopes: [UInt]

    func incremented(openScopes: [UInt]? = nil) -> PartialMatch {
      PartialMatch(style: style, matchIndex: matchIndex + 1, openScopes: openScopes ?? self.openScopes)
    }
  }
}