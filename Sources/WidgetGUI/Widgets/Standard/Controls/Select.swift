import GfxMath

private var optionSlots = [ObjectIdentifier: AnySlot]()

public class Select<O: Equatable>: ComposedWidget, SlotAcceptingWidgetProtocol {
  public typealias Option = O

  override public var name: String {
    "Select"
  }

  @ImmutableBinding var options: [Option]
  @MutableBinding var selectedOption: Option

  @Reference var valueContainer: Widget
  @Reference var optionsContainer: Widget
  @State var optionsVisibility: Visibility = .hidden

  public static var optionSlot: Slot<Option> {
    let optionTypeId = ObjectIdentifier(Option.self)
    if optionSlots[optionTypeId] == nil {
      optionSlots[optionTypeId] = Slot(key: "default", data: Option.self)
    }
    return optionSlots[optionTypeId] as! Slot<Option>
  }
  let optionSlotManager = SlotContentManager(Select.optionSlot)

  public init(options: ImmutableBinding<[Option]>, selectedOption: MutableBinding<Option>) {
    self._options = options
    self._selectedOption = selectedOption
  }

  public init(options: [Option], selectedOption: MutableBinding<Option>) {
    self._options = ImmutableBinding(get: { options })
    self._selectedOption = selectedOption

    super.init()

    self.onMouseEnter { [unowned self] in
      optionsVisibility = .visible
    }
  }

  @DirectContentBuilder override public var content: DirectContent {
    Container().with(classes: "value-field").withContent {
      Dynamic($selectedOption.immutable) { [unowned self] in
        optionSlotManager.buildContent(for: selectedOption)
      }
    }.connect(ref: $valueContainer)

    Container().with(classes: "options-field").with(styleProperties: {
      (\.$direction, .column)
      (\.$visibility, $optionsVisibility.immutable)
    }).withContent {
      Dynamic($options.immutable) { [unowned self] in
        Dynamic($selectedOption.immutable) {
          for option in options {
            Container().with(classes: option == selectedOption ? ["option", "selected"] : ["option"]).withContent {
              optionSlotManager.buildContent(for: option)
            }.onClick {
              selectedOption = option
            }
          }
        }
      }
    }.connect(ref: $optionsContainer)
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    valueContainer.layout(constraints: constraints)
    optionsContainer.layout(constraints: .unconstrained)
    optionsContainer.layoutedPosition.y = valueContainer.layoutedSize.height
    return valueContainer.layoutedSize + optionsContainer.layoutedSize.y
  }
}