#if os(macOS)
import AppKit
#endif
import GfxMath

public class ContextMenu {
  private let items: [Item]

  #if os(macOS)
  // same order as items (necessary for mapping actions)
  private var nsMenu: NSMenu?
  private var nsMenuItems: [NSMenuItem]?
  #endif

  public init(items: [Item]) {
    self.items = items

    setup()
  }

  private func setup() {
    #if os(macOS)

    let menu = NSMenu()
    let menuItems: [NSMenuItem] = items.map {
      let item = NSMenuItem(
        title: $0.title,
        action: #selector(onItemAction(_:)),
        keyEquivalent: "")
      item.isEnabled = true
      item.target = self
      menu.addItem(item)
      return item
    }

    self.nsMenu = menu
    self.nsMenuItems = menuItems

    #else
    fatalError("not implemented")
    #endif
  }

  public func show(at position: DVec2, in widget: Widget) {
    #if os(macOS)
    let window = widget.context.getWindow()
    let windowPosition = window.bounds.min
    print("SCREN SIZE", window.screen.size)
    let menuPosition = (windowPosition + widget.globalPosition + position) * DVec2(1, -1) + DVec2(0, window.screen.size.y)

    nsMenu?.popUp(
      positioning: nil,
      at: NSMakePoint(CGFloat(menuPosition.x), CGFloat(menuPosition.y)),
      in: nil
    )
    #else
    fatalError("not implemented")
    #endif
  }

  #if os(macOS)
  @objc private func onItemAction(_ sender: NSMenuItem) {
    if let index = nsMenuItems?.index(of: sender) {
      items[index].action()
    }
  } 
  #endif
}