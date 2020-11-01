public class List<Item>: SingleChildWidget {
  @ObservableProperty
  private var items: [Item]

  private var itemWidgets: [Widget] = []

  private let childBuilder: (Item) -> Widget

  private var firstDisplayedIndex = 0
  private var displayedCount = 0
  
  public init(
    _ items: ObservableProperty<[Item]>,
    @WidgetBuilder child childBuilder: @escaping (Item) -> Widget) {
      self._items = items
      self.childBuilder = childBuilder
  }

  override public func buildChild() -> Widget {
    itemWidgets = items.map(childBuilder)
    return ScrollArea { [unowned self] in
      Column {
        itemWidgets.map {
          $0.with {
            $0.visibility = .Hidden
          }
        }
      }
    }
  }

  private func updateDisplayedItems() {
    let currentFirstIndex = firstDisplayedIndex
  }
}