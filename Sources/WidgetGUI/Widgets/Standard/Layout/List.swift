public class List<Item>: SingleChildWidget {
  @ObservableProperty
  private var items: [Item]

  private var itemWidgets: [Widget] = []
  @Reference
  private var scrollArea: ScrollArea

  private let childBuilder: (Item) -> Widget

  private var firstDisplayedIndex = 0
  private var displayedCount = 0
  
  public init(
    _ items: ObservableProperty<[Item]>,
    @WidgetBuilder child childBuilder: @escaping (Item) -> Widget) {
      self._items = items
      self.childBuilder = childBuilder
      super.init()
      _ = self.onDestroy(self.$items.onChanged { [unowned self] _ in
        invalidateChild()
      })
      _ = self.onLayoutingFinished { [unowned self] _ in
        updateDisplayedItems()
      }
  }

  override public func buildChild() -> Widget {
    itemWidgets = items.map(childBuilder)
    return ScrollArea(scrollX: .Never) { [unowned self] in
      Column {
        itemWidgets.map {
          $0.with {
            $0.visibility = .Visible
          }
        }
      }
    }.connect(ref: $scrollArea).onScrollProgressChanged.chain { [unowned self] _ in
      updateDisplayedItems()
    }
  }

  private func updateDisplayedItems() {
    let currentFirstIndex = firstDisplayedIndex

    let currentScrollOffsets = scrollArea.offsets
    let currentScrollProgress = scrollArea.scrollProgress

    for widget in itemWidgets {
      if widget.y + widget.height >= currentScrollOffsets.y && widget.y <= currentScrollOffsets.y + scrollArea.height {
        widget.visibility = .Visible
      } else {
        widget.visibility = .Hidden
      }
    }
  }
}