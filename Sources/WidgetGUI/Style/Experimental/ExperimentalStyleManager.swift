extension Experimental {
  public class StyleManager {
    public init() {}

    public func processTree(_ initialWidget: Widget) {
      /**
      what is the goal?:
        - distribute the styles found in the tree
        - according to the selectors

        - what to consider:
          - Selectors should probably be aggregated before use!
          - correct order of applied styles --> properties overwrite in expected way
          - scopes
          - parent extending selector at root level starts matching
          the parent Widget regardless of scope (probably?)
          - disabled scope for a selector
          - selector part opens up a level of scope
          - pseudo classes (probably checked automatically by the selector part object)
          - pseudo elements
          - consider selector specifity at the same level
          - don't reapply the same style to a Widget
          if it has already been applied because of a lower level match

        implementation plan/discussion:

        - make a list of styles where the selector started to match on the current parent
        - fetch styles from parents, up to initial widget (including it)
        - process the styles of the parent chain --> try to apply currently available styles
        to parents to check whether sub styles are freed
        - try to apply all styles available so far to initial widget
        - go down the tree of initial widget
        - iterate breadth first
        - get the provided styles of any child
        - try to apply all available style selectors to the current tested widget
        - repeat

        - from a focus on one Widget perspective:
          - keep track of styles that need to be checked for a next selector part match
          as a list of lists to reflect which levels they originated at and be able delete them
          when traversing up (so that not styles from a level below the current widget are applied to it)
          - need to add information about which part needs to be checked next for eached partially matched style
          - keep track of styles that can be checked for a match
          (all styles that originated above and in the Widget)
          - for every Widget that is found (depth first):
            - check whether the previously partially matching styles continue to match
              - if they do
                - if the selector has no further parts, add it to the Widget that it was tested on
                - else, add the style again to the current level, so every style from a level above
                can occur multiple times in the current level, if it continues to partially match
                on multiple Widgets
              - if they do not, delete them from the list (the level they are at)
          - keep doing this until the Widget tree under the initial Widget has been fully traversed
        
        - maybe do breadth first?
          - in that case there would be a list which contains the iterators to the next branch (children of a Widget)
          with a list of all styles that could be checked for a match in that branch
          and a list of styles that partially applied to that branch at some point
          - every child Widget becomes a new branch with that information and gets appended to the list
          of branches to follow
          - the styles are applied in a a way that processes the Widget tree layer by layer

        - which is the better approach?
          - is order of styles respected?
            - for depth:
              - since styles defined later are appended to the list of all styles
              - and partial matches are also appended to the list of matches
              - styles defined later or that matched closer to the Widget will overwrite
              styles defined earlier or matched earlier
              - does this make sense? yes
              - in css specifity probably also counts, a selector where parts are more specific at one
              level will be more important than a selector which has less specifity at the same level
            - so selector importance:
              - match started closer to the Widget -> more important
              - matches that started at the same level, the one with more parts matched up to the Widget is more important
              - matches that are equal in that respect also, the one with the more specific parts
              (more classes, pseudo classes -> assign a weight to each part) is more important
              - maybe like this: the selector with the more specific part nearer the end of the selector is more important
              - if two selectors are same in all those aspects: the style which was defined later/closer to the Widget is more important
              - is this necessary?
                - it makes it more complicated to reason about the whole thing by just looking at the style definitions
                - reduce the importance thing to: closer matches win, else closer defined to widget wins
                this should probably be the result of how the styles are processed
      */

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
      queue.append(QueueEntry(iterator: initialWidget.visitChildren(), partialMatches: partialMatches))

      while queue.count > 0 {
        var entry = queue.removeFirst()

        while let widget = entry.iterator.next() {
          let (newPartialMatches, fullMatches) = continueMatching(previousPartialMatches: entry.partialMatches, widget: widget)
          widget.experimentalMatchedStyles = fullMatches
          queue.append(QueueEntry(iterator: widget.visitChildren(), partialMatches: newPartialMatches))
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

        for style in widget.experimentalProvidedStyles {
          // use match index -2 to delay matching of non extending styles
          // to the children of the current widget
          partialMatchesToCheck.append(PartialMatch(
            style: style,
            matchIndex: style.selector.extendsParent ? -1 : -2,
            openScopes: []/* TODO: should every style have a sourceScope attribute? */))
        }

        var fullMatches = [Experimental.Style]()
        var newPartialMatches = [PartialMatch]()

        var partialMatchIndex = 0
        while partialMatchIndex < partialMatchesToCheck.count {
          let checkPartialMatch = partialMatchesToCheck[partialMatchIndex]
          
          if checkPartialMatch.matchIndex == -2 {
            partialMatchesToCheck[partialMatchIndex] = checkPartialMatch.incremented()
          } else if checkPartialMatch.style.selector.partCount == 0 ||
            checkPartialMatch.style.selector[part: checkPartialMatch.matchIndex + 1].selects(widget) {
              if checkPartialMatch.style.selector.partCount - 1 > checkPartialMatch.matchIndex + 1 {
                newPartialMatches.append(checkPartialMatch.incremented())
              } else {
                fullMatches.append(checkPartialMatch.style)
                // the sub styles of the matched style
                // can can now match the current widget (if they extend their parent)
                // and the children as well
                partialMatchesToCheck.insert(contentsOf: checkPartialMatch.style.children.map {
                  // use match index -2 to delay matching of non extending styles
                  // to the children of the current widget
                  PartialMatch(style: $0, matchIndex: $0.selector.extendsParent ? -1 : -2, openScopes: [])
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
      var iterator: Widget.ChildIterator
      let partialMatches: [PartialMatch]
    }

    private struct PartialMatch {
      let style: Experimental.Style
      let matchIndex: Int
      let openScopes: [UInt]

      func incremented() -> PartialMatch {
        PartialMatch(style: style, matchIndex: matchIndex + 1, openScopes: openScopes)
      }
    }
  }
}