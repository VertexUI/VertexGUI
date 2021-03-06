import XCTest
@testable import WidgetGUI

class StylePropertiesResolverTests: XCTestCase {
  enum Properties: String, StyleKey, DefaultStyleKeys {
    case property1
    case property2
  }

  let propertySupportDefinitions = StylePropertySupportDefinitions {
    (Properties.property1, type: .specific(Double.self))
    (Properties.property2, type: .specific(Double.self))
  }

  func testSimpleDirectPropertiesOnly() {
    let resolver = StylePropertiesResolver(propertySupportDefinitions: propertySupportDefinitions)
    resolver.directProperties = [
      StyleProperties {
        (Properties.property1, 1.0)
        (Properties.property1, 2.0)
        (Properties.property2, 3.0)
      },
      StyleProperties {
        (Properties.property1, 4.0)
      }
    ]
    resolver.resolve()

    XCTAssertEqual(resolver[Properties.property1], 4.0)
    XCTAssertEqual(resolver[Properties.property2], 3.0)
  }

  func testSimpleOnlyStyle() {
    let resolver = StylePropertiesResolver(propertySupportDefinitions: propertySupportDefinitions)
    resolver.styles = [
      Style("") {
        (Properties.property1, 1.0)
        (Properties.property1, 2.0)
        (Properties.property2, 4.0)
      },
      Style("") {
        (Properties.property1, 3.0)
      } 
    ]
    resolver.resolve()

    XCTAssertEqual(resolver[Properties.property1], 3.0)
    XCTAssertEqual(resolver[Properties.property2], 4.0)
  }

  func testInheritValue() {
    let resolver = StylePropertiesResolver(propertySupportDefinitions: propertySupportDefinitions)
    resolver.directProperties = [
      StyleProperties {
        (Properties.property1, .inherit)
      }
    ]
    resolver.styles = [
      Style("") {
        (Properties.property2, .inherit)
      }
    ]
    resolver.inheritableValues = [
      Properties.property1.asString: 1.0,
      Properties.property2.asString: 2.0
    ]
    resolver.resolve()

    XCTAssertEqual(resolver[Properties.property1], 1.0)
    XCTAssertEqual(resolver[Properties.property2], 2.0)
  }

  func testDirectReactiveInputNonReactiveOutput() {
    let resolver = StylePropertiesResolver(propertySupportDefinitions: propertySupportDefinitions)
    let reactiveInputProperty = MutableProperty(1.0)
    resolver.directProperties = [
      StyleProperties {
        (Properties.property1, reactiveInputProperty)
      }
    ]

    resolver.resolve()
    XCTAssertEqual(resolver[Properties.property1], 1.0)

    reactiveInputProperty.value = 2.0
    XCTAssertEqual(resolver[Properties.property1], 2.0)
  }

  func testDirectNonReactiveInputReactiveOutput() {
    let resolver = StylePropertiesResolver(propertySupportDefinitions: propertySupportDefinitions)
    resolver.directProperties = [
      StyleProperties {
        (Properties.property1, 1.0)
      }
    ]
    let outputProperty: ObservableProperty<Double?> = resolver[reactive: Properties.property1]
    var onHasValueChangedCallCount = 0
    var onChangedCallCount = 0
    _ = outputProperty.onHasValueChanged {
      onHasValueChangedCallCount += 1
    }
    _ = outputProperty.onChanged { _ in
      onChangedCallCount += 1
    }
  
    resolver.resolve()
    XCTAssertEqual(onHasValueChangedCallCount, 0)
    XCTAssertEqual(onChangedCallCount, 1)
    XCTAssertEqual(outputProperty.value, 1)

    resolver.directProperties = [
      StyleProperties {
        (Properties.property1, 2.0)
      }
    ]
    resolver.resolve()
    XCTAssertEqual(onHasValueChangedCallCount, 0)
    XCTAssertEqual(onChangedCallCount, 2)
    XCTAssertEqual(outputProperty.value, 2)
  }

  func testDirectReactiveInputReactiveOutput() {
    let resolver = StylePropertiesResolver(propertySupportDefinitions: propertySupportDefinitions)
    let inputProperty = MutableProperty<Double>()
    resolver.directProperties = [
      StyleProperties {
        (Properties.property1, inputProperty)
      }
    ]
    let outputProperty: ObservableProperty<Double?> = resolver[reactive: Properties.property1]
    var outputOnHasValueChangedCallCount = 0
    var outputOnChangedCallCount = 0
    _ = outputProperty.onHasValueChanged {
      outputOnHasValueChangedCallCount += 1
    }
    _ = outputProperty.onChanged { _ in
      outputOnChangedCallCount += 1
    }

    XCTAssertTrue(outputProperty.hasValue)

    resolver.resolve()
    XCTAssertTrue(outputProperty.hasValue)
    XCTAssertEqual(outputOnHasValueChangedCallCount, 0)
    XCTAssertEqual(outputOnChangedCallCount, 1)

    inputProperty.value = 1
    XCTAssertTrue(outputProperty.hasValue)
    XCTAssertEqual(outputOnHasValueChangedCallCount, 0)
    XCTAssertEqual(outputOnChangedCallCount, 2)
    XCTAssertEqual(outputProperty.value, 1)

    inputProperty.value = 2
    XCTAssertTrue(outputProperty.hasValue)
    XCTAssertEqual(outputOnHasValueChangedCallCount, 0)
    XCTAssertEqual(outputOnChangedCallCount, 3)
    XCTAssertEqual(outputProperty.value, 2)
  }

  func testReactiveInputReactiveOutputInherit() {
    let resolver = StylePropertiesResolver(propertySupportDefinitions: propertySupportDefinitions)
    let inputProperty = MutableProperty<StyleValue>()
    resolver.directProperties = [
      StyleProperties {
        (Properties.property1, inputProperty)
      }
    ]
    resolver.inheritableValues = [
      Properties.property1.asString: 1.0
    ]
    let outputProperty: ObservableProperty<Double?> = resolver[reactive: Properties.property1]
    resolver.resolve()

    inputProperty.value = SpecialStyleValue.inherit
    XCTAssertEqual(resolver[Properties.property1], 1.0)
    XCTAssertEqual(outputProperty.value, 1.0)
  }

  static var allTests = [
    ("testSimpleDirectPropertiesOnly", testSimpleDirectPropertiesOnly),
    ("testSimpleOnlyStyle", testSimpleOnlyStyle),
    ("testInheritValue", testInheritValue),
    ("testDirectReactiveInputNonReactiveOutput", testDirectReactiveInputNonReactiveOutput),
    ("testDirectNonReactiveInputReactiveOutput", testDirectNonReactiveInputReactiveOutput),
    ("testDirectReactiveInputReactiveOutput", testDirectReactiveInputReactiveOutput),
    ("testReactiveInputReactiveOutputInherit", testReactiveInputReactiveOutputInherit)
  ]
}