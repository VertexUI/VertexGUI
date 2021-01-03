import XCTest
@testable import SwiftGUI
@testable import ExperimentalReactiveProperties

final class ReactivePropertyTests: XCTestCase {
  class UniDirectionalBindingSourceWidget: Widget {
    @ExperimentalReactiveProperties.MutableProperty
    var property1: String
    
    init<P1: MutablePropertyProtocol>(property1: P1) where P1.Value == String {
      super.init()
      property1.bind(self.$property1)
    }
  }

  class UniDirectionalBindingSinkWidget: Widget {
    @ExperimentalReactiveProperties.MutableProperty
    var property1: String

    init<P1: ReactiveProperty>(property1: P1) where P1.Value == String {
      super.init()
      self.$property1.bind(property1)
    }
  }

  class BiDirectionalBindingWidget: Widget {
    @ExperimentalReactiveProperties.MutableProperty
    var property1: String

    let onEvent1 = EventHandlerManager<String>()
    let onEvent2 = EventHandlerManager<Void>()

    init<P1: MutablePropertyProtocol>(property1: P1) where P1.Value == String {
      super.init()
      self.$property1.bindBidirectional(property1)
      _ = self.$property1.onChanged {
        self.onEvent1.invokeHandlers($0.new)

        if $0.old != $0.new {
          self.onEvent2.invokeHandlers(())
        }
      }
    }
  }

  class MutableComputedPropertyWidget: Widget {
    @ExperimentalReactiveProperties.MutableComputedProperty
    var property1: String

    init<P1: MutablePropertyProtocol>(property1 passedIn1: P1) where P1.Value == String {
      self._property1 = MutableComputedProperty(compute: {
        passedIn1.value
      }, apply: {
        passedIn1.value = $0
      })
    }
  }

  class MutableComputedPropertyWithDelayedDependencyAvailabilityWidget: Widget {
    @ExperimentalReactiveProperties.MutableComputedProperty
    var property1: String

    @Inject
    var dependency1: ExperimentalReactiveProperties.MutableProperty<String>

    let onEvent1 = EventHandlerManager<String>()

    init() {
      super.init()
      _ = self._property1.onChanged {
        self.onEvent1.invokeHandlers($0.new)
      }
      _ = onDependenciesInjected {
        self._property1.reinit(compute: {
          self.dependency1.value
        }, apply: {
          self.dependency1.value = $0
        })
      }
    }
  }

  func testOneWidgetToAnotherUniDirectionalPropertyBinding() {
    let mutableProperty = ExperimentalReactiveProperties.MutableProperty<String>()

    let reference1 = Reference<UniDirectionalBindingSourceWidget>()
    let reference2 = Reference<UniDirectionalBindingSinkWidget>()
    let root = MockRoot(rootWidget: MockContainerWidget {
      UniDirectionalBindingSourceWidget(property1: mutableProperty).connect(ref: reference1)
      UniDirectionalBindingSinkWidget(property1: mutableProperty).connect(ref: reference2)
    })

    reference1.referenced!.property1 = "test2"

    XCTAssertEqual(reference1.referenced!.property1, "test2")
    XCTAssertEqual(reference2.referenced!.property1, "test2")
    XCTAssertEqual(mutableProperty.value, "test2")
  }

  func testUniDirectionalPropertyBindingWidgetPropertyDestroyed() {
    let passedInProperty = ExperimentalReactiveProperties.MutableProperty<String>()
    let widget = UniDirectionalBindingSinkWidget(property1: passedInProperty)
    let root = MockRoot(rootWidget: widget)

    passedInProperty.value = "test1"
    XCTAssertEqual(widget.property1, "test1")
    XCTAssertEqual(widget.$property1.registeredBindings.count, 1)

    passedInProperty.destroy()
    XCTAssertEqual(widget.$property1.registeredBindings.count, 0)
  }

  func testBiDirectionalBindingWithWidget() {
    let passedInProperty = ExperimentalReactiveProperties.MutableProperty<String>("test1")
    let widget = BiDirectionalBindingWidget(property1: passedInProperty)
    let root = MockRoot(rootWidget: widget)
    var widgetEvent1Fired = false
    let removeWidgetEvent1Handler = widget.onEvent1 {
      widgetEvent1Fired = true
      XCTAssertEqual($0, "test2")
    }
    var widgetEvent2Fired = false
    _ = widget.onEvent2 {
      widgetEvent2Fired = true
    }

    passedInProperty.value = "test2"
    XCTAssertTrue(widgetEvent1Fired)
    XCTAssertTrue(widgetEvent2Fired)
    XCTAssertEqual(widget.property1, "test2")
    removeWidgetEvent1Handler()

    widget.property1 = "test3"
    XCTAssertEqual(passedInProperty.value, "test3")
  }

  func testBiDirectionalBindingWidgetBindingPropertyDestroyed() {
    let passedInProperty = ExperimentalReactiveProperties.MutableProperty<String>()
    let widget = BiDirectionalBindingWidget(property1: passedInProperty)
    let root = MockRoot(rootWidget: widget)

    passedInProperty.value = "test1"
    XCTAssertEqual(widget.property1, "test1")
    XCTAssertEqual(widget.$property1.registeredBindings.count, 1)

    passedInProperty.destroy()
    XCTAssertEqual(widget.$property1.registeredBindings.count, 0)
  }

  func testMutableComputedPropertyWidgetOperatingOnPassedInProperty() {
    let passedInProperty = ExperimentalReactiveProperties.MutableProperty<String>("test0")
    let widget = MutableComputedPropertyWidget(property1: passedInProperty)
    let root = MockRoot(rootWidget: widget)
    
    XCTAssertTrue(widget.$property1.hasValue)
    XCTAssertEqual(widget.property1, "test0")

    passedInProperty.value = "test1"
    XCTAssertTrue(widget.$property1.hasValue)
    XCTAssertEqual(widget.property1, "test1")

    widget.property1 = "test2"
    XCTAssertEqual(passedInProperty.value, "test2")
  }

  func testMutableComputedPropertyWithDelayedDependencyAvailabilityWidget() {
    let dependency = ExperimentalReactiveProperties.MutableProperty<String>("test1")
    let widget = MutableComputedPropertyWithDelayedDependencyAvailabilityWidget()
    let root = MockRoot(rootWidget: DependencyProvider(provide: [Dependency(dependency)]) {
      widget
    })
    var widgetEvent1Fired = false
    _ = widget.onEvent1 {
      widgetEvent1Fired = true
      XCTAssertEqual($0, "test2")
    }

    XCTAssertTrue(widget.$property1.hasValue)
    XCTAssertEqual(widget.property1, "test1")

    dependency.value = "test2"
    XCTAssertEqual(widget.property1, "test2")
    XCTAssertTrue(widgetEvent1Fired)
  }

  func testWidgetTreeDefinitionWithOnTheFlyMutableComputedProperty() {
    let dependency = ExperimentalReactiveProperties.MutableProperty("test1")
    let reference = Reference<BiDirectionalBindingWidget>()
    let root = MockRoot(rootWidget: MockContainerWidget {
      MockContainerWidget {
        BiDirectionalBindingWidget(property1: MutableComputedProperty(compute: {
          dependency.value
        }, apply: {
          dependency.value = $0
        })).connect(ref: reference)
      }
    })
    XCTAssertTrue(reference.referenced!.$property1.hasValue)
    XCTAssertEqual(reference.referenced!.property1, "test1")

    dependency.value = "test2" 
    XCTAssertEqual(reference.referenced!.property1, "test2")

    reference.referenced!.property1 = "test3"
    XCTAssertEqual(dependency.value, "test3")
  }

  func testWidgetDeinitializedIfSelfCapturedInPropertyHandlers() {
    let reference = Reference<MutableComputedPropertyWithDelayedDependencyAvailabilityWidget>()
    var root = Optional(MockRoot(rootWidget: DependencyProvider(provide: [
      Dependency(ExperimentalReactiveProperties.MutableProperty("test"))]) {
        MutableComputedPropertyWithDelayedDependencyAvailabilityWidget().connect(ref: reference)
    }))

    XCTAssertNotNil(reference.referenced)

    var widgetDestroyed = false
    _ = reference.referenced!.onDestroy {
      widgetDestroyed = true
    }
    root = nil

    XCTAssertTrue(widgetDestroyed)
    XCTAssertNil(reference.referenced)
  }

  static var allTests = [
    ("testOneWidgetToAnotherUniDirectionalPropertyBinding", testOneWidgetToAnotherUniDirectionalPropertyBinding),
    ("testUniDirectionalPropertyBindingWidgetPropertyDestroyed", testUniDirectionalPropertyBindingWidgetPropertyDestroyed),
    ("testBiDirectionalBindingWithWidget", testBiDirectionalBindingWithWidget),
    ("testBiDirectionalBindingWidgetBindingPropertyDestroyed", testBiDirectionalBindingWidgetBindingPropertyDestroyed),
    ("testMutableComputedPropertyWidgetOperatingOnPassedInProperty", testMutableComputedPropertyWidgetOperatingOnPassedInProperty),
    ("testMutableComputedPropertyWithDelayedDependencyAvailabilityWidget", testMutableComputedPropertyWithDelayedDependencyAvailabilityWidget),
    ("testWidgetTreeDefinitionWithOnTheFlyMutableComputedProperty", testWidgetTreeDefinitionWithOnTheFlyMutableComputedProperty),
    ("testWidgetDeinitializedIfSelfCapturedInPropertyHandlers", testWidgetDeinitializedIfSelfCapturedInPropertyHandlers)
  ]
}