import XCTest
@testable import WidgetGUI

class StylePropertySupportDefinitionsTests: XCTestCase {
  func testMerging() {
    var definitions1 = StylePropertySupportDefinitions {
      ("property1", type: .specific(String.self))
    }
    var definitions2 = StylePropertySupportDefinitions {
      ("property2", type: .specific(String.self))
    }
    var merged = try! StylePropertySupportDefinitions(merge: [definitions1, definitions2])
    XCTAssertEqual(merged.definitions.count, 2)
    XCTAssertEqual(merged.definitions.map { $0.key.asString }, ["property1", "property2"])

    definitions1 = StylePropertySupportDefinitions {
      ("property1", type: .specific(String.self))
    }
    definitions2 = StylePropertySupportDefinitions {
      ("property1", type: .specific(String.self))
    }
    var errorInstance: StylePropertySupportDefinitions.MergingError? = nil
    do {
      merged = try StylePropertySupportDefinitions(merge: [definitions1, definitions2])
    } catch let error as StylePropertySupportDefinitions.MergingError {
      errorInstance = error
    } catch {
      assertionFailure("did not a different kind of error")
    }
    XCTAssertNotNil(errorInstance)
    if case let .duplicateKey(key, sources) = errorInstance {
      XCTAssertEqual(key, "property1")
      XCTAssertEqual(sources, [.unknown, .unknown])
    }
  }

  func testValidationAndFiltering() {
    let definitions = StylePropertySupportDefinitions {
      ("property1", type: .specific(Double.self))
    }
    let (validProperties, validationResults) = definitions.process([
      StyleProperty(key: "property1", value: 1.0)
    ])
    XCTAssertEqual(validProperties.count, 1)
  }

  static var allTests = [
    ("testMerging", testMerging),
    ("testValidationAndFiltering", testValidationAndFiltering)
  ]
}