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

      var availableStyles = [Experimental.Style]()
      var partialMatches = [PartialMatch]()

      for (index, parent) in initialParents.enumerated() {
        var availableStylesForParent = availableStyles

        for style in parent.experimentalProvidedStyles {
          if style.selector.extendsParent {
            availableStylesForParent.append(style)
          } else {
            availableStyles.append(style)
            availableStylesForParent.append(style)
          }
        }

        let (newPartialMatches, fullMatchesForParent) = continueMatching(
          previousPartialMatches: partialMatches,
          availableStyles: availableStylesForParent,
          widget: parent)

        let newAvailableStylesForChildren: [Experimental.Style]
        if index < initialParents.count - 1 {
          newAvailableStylesForChildren = applyStyles(fullMatchesForParent, to: parent, dryRun: true)
        } else {
          newAvailableStylesForChildren = applyStyles(fullMatchesForParent, to: parent, dryRun: false)
        }

        partialMatches.append(contentsOf: newPartialMatches)
        // TODO: this might not work as expected, since the freed sub styles might need
        // to be added right behind their parent to ensure correct overwriting
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!
        availableStyles.append(contentsOf: newAvailableStylesForChildren)
      }

      // apply what can be applied to the initial widget

      var queue = [QueueEntry]()
    }

    private func continueMatching(previousPartialMatches: [PartialMatch], availableStyles: [Experimental.Style], widget: Widget) -> (partialMatches: [PartialMatch], fullMatches: [Experimental.Style]) {
      var partialMatches = [PartialMatch]()
      var fullMatches = [Experimental.Style]()

      for previousPartialMatch in previousPartialMatches {
        let selectorPartToCheck = previousPartialMatch.style.selector[part: previousPartialMatch.matchIndex + 1]

        if selectorPartToCheck.selects(widget) {
          if previousPartialMatch.style.selector.partCount - 1 > previousPartialMatch.matchIndex + 1 {
            partialMatches.append(previousPartialMatch.incremented())
          } else {
            fullMatches.append(previousPartialMatch.style)
          }
        } else {
          // TODO: when direct parent > child syntax is there
          // (meaning no unknown number of Widgets inbetween)
          // then need to check whether the part is of this kind
          // and if yes remove the whole partial match
          partialMatches.append(previousPartialMatch)
        }
      }

      return (partialMatches: partialMatches, fullMatches: fullMatches)
    }

    /**
    - Parameter dryRun: Don't set any styles on the widget,
    Use to get the returned value without modifying the widget.
    - Returns: The sub styles of the applied styles.
    */
    private func applyStyles(_ styles: [Experimental.Style], to widget: Widget, dryRun: Bool = false) -> [Experimental.Style] {
      var freedStyles = [Experimental.Style]()

      for style in styles {

      }

      return freedStyles
    }

    private struct QueueEntry {
      let iterator: Widget.ChildIterator
      let availableStyles: [Experimental.Style]
      let partialMatches: [PartialMatch]
    }

    private struct PartialMatch {
      let style: Experimental.Style
      let matchIndex: Int

      func incremented() -> PartialMatch {
        PartialMatch(style: style, matchIndex: matchIndex + 1)
      }
    }
  }
}