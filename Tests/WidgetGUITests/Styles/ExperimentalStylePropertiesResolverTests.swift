import XCTest
@testable import WidgetGUI

class ExperimentalStylePropertiesResolverTests: XCTestCase {
  enum Properties: String, StyleKey, ExperimentalDefaultStyleKeys {
    case property1
    case property2
  }

  let propertySupportDefinitions = Experimental.StylePropertySupportDefinitions {
    (Properties.property1, type: .specific(Double.self))
    (Properties.property2, type: .specific(Double.self))
  }

  func testSimpleDirectPropertiesOnly() {
    var resolver = Experimental.StylePropertiesResolver(propertySupportDefinitions: propertySupportDefinitions)
    resolver.directProperties = [
      Experimental.StyleProperties {
        (Properties.property1, 1.0)
        (Properties.property1, 2.0)
        (Properties.property2, 3.0)
      },
      Experimental.StyleProperties {
        (Properties.property1, 4.0)
      }
    ]
    resolver.resolve()

    XCTAssertEqual(resolver[Properties.property1], 4.0)
    XCTAssertEqual(resolver[Properties.property2], 3.0)
  }

  func testSimpleOnlyStyle() {
    var resolver = Experimental.StylePropertiesResolver(propertySupportDefinitions: propertySupportDefinitions)
    resolver.styles = [
      Experimental.Style("") {
        (Properties.property1, 1.0)
        (Properties.property1, 2.0)
        (Properties.property2, 4.0)
      },
      Experimental.Style("") {
        (Properties.property1, 3.0)
      } 
    ]
    resolver.resolve()

    XCTAssertEqual(resolver[Properties.property1], 3.0)
    XCTAssertEqual(resolver[Properties.property2], 4.0)
  }

  static var allTests = [
    ("testSimpleDirectPropertiesOnly", testSimpleDirectPropertiesOnly),
    ("testSimpleOnlyStyle", testSimpleOnlyStyle)
  ]
}