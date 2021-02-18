import VisualAppBase
import Events

extension Widget {
  public class LifecycleMethodInvocationQueue {
    var entries: [Entry] = []

    let onEntryAdded = EventHandlerManager<Entry>()

    public init() {}

    public func queue(_ entry: Entry) {
      entries.append(entry)
      onEntryAdded.invokeHandlers(entry)
    }

    public func clear() {
      entries = []
    }

    public func iterate() -> Iterator {
      let iterator = Iterator(entries: entries)
      _ = iterator.onDestroy(onEntryAdded.addHandler { [unowned iterator] in
        iterator.entries.append($0)
      })
      return iterator
    }

    public func iterateSubTreeRoots() -> Iterator {
      // TODO: implement iterator in such a way that when a new item is added to the queue
      // this item is inserted into the iterator at the correct position -> if at a higher level
      // than currently at, add it as the item for the next iteration (items already iterated are discarded by the iterator)
      // and remove the items below it
      // if it is not included in a tree path already in the iterator, add it to the end
      var byTreePath: [TreePath: Entry] = [:]
      outer: for entry in entries {
        for (otherPath, otherEntry) in byTreePath {
          if entry.target.treePath.isParent(of: otherPath) {
            byTreePath[otherPath] = nil
          } else if otherPath.isParent(of: entry.target.treePath) {
            continue outer
          }
        }

        byTreePath[entry.target.treePath] = entry
      }

      return Iterator(entries: Array(byTreePath.values))
    }

    public class Entry {
      public var method: LifecycleMethod
      public var target: Widget
      public var sender: Widget
      public var reason: LifecycleMethodInvocationReason
      public var tick: Tick

      public init(method: LifecycleMethod, target: Widget, sender: Widget, reason: LifecycleMethodInvocationReason, tick: Tick) {
        self.method = method
        self.target = target
        self.sender = sender
        self.reason = reason
        self.tick = tick
      }
    }

    public class Iterator: IteratorProtocol {
      var entries: [Entry]
      var ownedObjects: [Any] = []
      let onDestroy = EventHandlerManager<Void>()

      public init(entries: [Entry]) {
        self.entries = entries
      }

      public func next() -> Entry? {
        entries.popLast()
      }

      deinit {
        onDestroy.invokeHandlers()
      }
    }
  }
}