import SwiftGUI

public class TodoListItemView: ContentfulWidget {
  @Inject private var store: ExperimentalTodoStore

  private var item: TodoItem
  private var editable: Bool
  private var checkable: Bool

  @State private var editing: Bool = false
  @State private var updatedDescriptionBuffer: String = ""

  public init(_ item: TodoItem, editable: Bool = false, checkable: Bool = true) {
    self.item = item
    self.editable = editable
    self.checkable = checkable
    updatedDescriptionBuffer = item.description
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().with(classes: ["root-container"]).withContent { [unowned self] in
      TaskCompletionButton(item.completed).with(classes: ["completion-button"]).onClick {
        if checkable {
          var updatedItem = item
          updatedItem.completed = !updatedItem.completed
          store.commit(.updateTodoItem(updatedItem: updatedItem))
        }
      }

      Dynamic($editing) {
        if editing {

          TextInput(text: $updatedDescriptionBuffer.mutable).with(classes: ["description"]).with { instance in
            _ = instance.onMounted {
              instance.requestFocus()
            }

            instance.onKeyUp {
              if $0.key == .Return {
                var updatedItem = item
                updatedItem.description = updatedDescriptionBuffer
                store.commit(.updateTodoItem(updatedItem: updatedItem))
              }
            }
          }
        } else {

          Text(item.description).with(classes: ["description"]).with { instance in
            if editable {
              instance.onClick {
                editing = true
              }
            }
          }
        }
      }
    }
  }

  override public var experimentalStyle: Experimental.Style {
    Experimental.Style("&") {
      (\.$foreground, .white)
      (\.$padding, Insets(top: 16, right: 24, bottom: 16, left: 24))
      (\.$borderColor, AppTheme.listItemDividerColor)
      (\.$borderWidth, BorderWidth(bottom: 1.0))
    } nested: {
      Experimental.Style(".root-container", Container.self) {
        (\.$alignContent, .center)
      }

      Experimental.Style(".completion-button") {
        (\.$foreground, AppTheme.primaryColor)
        (\.$margin, Insets(right: 24))
      } nested: {

        Experimental.Style("&:hover") {
          (\.$foreground, AppTheme.primaryColor.darkened(40))
        }
      }

      Experimental.Style(".description") {
        (\.$alignSelf, .center)
        (\.$grow, 1)
      }
    }
  }
}
