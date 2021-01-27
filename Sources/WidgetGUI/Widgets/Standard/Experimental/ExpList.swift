import ExperimentalReactiveProperties
import VisualAppBase
import GfxMath

extension Experimental {
  private class InternalList: Widget {
    override internal var children: [Widget] {
      didSet {
        if mounted {
          for child in children {
            if !child.mounted {
              self.mountChild(child)
            }
          }
          self.invalidateLayout()
          self.invalidateRenderState()
        }
      }
    }

    internal init() {}

    override public func getBoxConfig() -> BoxConfig {
      BoxConfig(preferredSize: .zero)
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      var currentPosition = DPoint2.zero
      var maxWidth = 0.0

      for child in children {
        let childConstraints = BoxConstraints(minSize: .zero, maxSize: constraints.maxSize)
        child.layout(constraints: childConstraints)

        child.position = currentPosition

        currentPosition.y += child.height
        if child.width > maxWidth {
          maxWidth = child.width
        }
      }

      return constraints.constrain(DSize2(maxWidth, currentPosition.y))
    }

    override public func renderContent() -> RenderObject? {
      //print("EXP LIST RENDERS", children)
      return super.renderContent()
    }
  }

  public class List<Item: Equatable>: Experimental.ComposedWidget {
    @ExperimentalReactiveProperties.ObservableProperty
    private var items: [Item]
    private var previousItems: [Item] = []
    private var itemWidgets: [Widget] = []

    @Reference
    private var itemLayoutContainer: InternalList
    @Reference
    private var scrollArea: ScrollArea

    private let childBuilder: (Item) -> Widget

    private var firstDisplayedIndex = 0
    private var displayedCount = 0
    
    public init<P: ReactiveProperty>(
      _ itemsProperty: P,
      @WidgetBuilder child childBuilder: @escaping (Item) -> Widget) where P.Value == Array<Item> {
        self.childBuilder = childBuilder
        super.init()
        self.$items.bind(itemsProperty)
        _ = self.onDestroy(self.$items.onChanged { [unowned self] in
          processItemUpdate(old: $0.old, new: $0.new)
        })
        _ = self.onMounted { [unowned self] in
          processItemUpdate(old: [], new: items)
        }
        _ = self.onLayoutingFinished { [unowned self] _ in
          updateDisplayedItems()
        }
    }

    private func processItemUpdate(old: [Item], new: [Item]) {
      var updatedItemWidgets = [Widget]()

      var usedOldIndices = [Int]()

      outer: for newItem in new {
        var foundOldIndex: Int?

        for (oldIndex, oldItem) in old.enumerated() {
          if oldItem == newItem, !usedOldIndices.contains(oldIndex), itemWidgets.count > oldIndex {
            foundOldIndex = oldIndex
            break
          }
        }

        if let oldIndex = foundOldIndex {
          updatedItemWidgets.append(itemWidgets[oldIndex])
          usedOldIndices.append(oldIndex)
        } else {
          updatedItemWidgets.append(childBuilder(newItem))
        }
      }

      itemWidgets = updatedItemWidgets

      if mounted {
        itemLayoutContainer.children = itemWidgets
      }
    }

    override public func performBuild() {
      return //ScrollArea(scrollX: .Never) { [unowned self] in
       rootChild = InternalList().connect(ref: $itemLayoutContainer)
     // }.connect(ref: $scrollArea).onScrollProgressChanged.chain { [unowned self] _ in
     //   updateDisplayedItems()
     // }
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      //print("EXP LIST LAYOUTING")
      return super.performLayout(constraints: constraints)
    }

    private func updateDisplayedItems() {
      let currentFirstIndex = firstDisplayedIndex

      //let currentScrollOffsets = scrollArea.offsets
      //let currentScrollProgress = scrollArea.scrollProgress

      /*for widget in itemWidgets {
        if widget.y + widget.height >= currentScrollOffsets.y && widget.y <= currentScrollOffsets.y + scrollArea.height {
          widget.visibility = .Visible
        } else {
          widget.visibility = .Hidden
        }
      }*/
    }
  }
}