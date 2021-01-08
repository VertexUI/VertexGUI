import XCTest
@testable import WidgetGUI

class ExperimentalStylePropertySupportDefinitionsTests: XCTestCase {
  func testMerging() {
    var definitions1 = Experimental.StylePropertySupportDefinitions {
      ("property1", type: .specific(String.self))
    }
    var definitions2 = Experimental.StylePropertySupportDefinitions {
      ("property2", type: .specific(String.self))
    }
    var merged = try! Experimental.StylePropertySupportDefinitions(merge: definitions1, definitions2)
    XCTAssertEqual(merged.definitions.count, 2)
    XCTAssertEqual(merged.definitions.map { $0.key.asString }, ["property1", "property2"])

    definitions1 = Experimental.StylePropertySupportDefinitions {
      ("property1", type: .specific(String.self))
    }
    definitions2 = Experimental.StylePropertySupportDefinitions {
      ("property1", type: .specific(String.self))
    }
    var errorInstance: Experimental.StylePropertySupportDefinitions.MergingError? = nil
    do {
      merged = try Experimental.StylePropertySupportDefinitions(merge: definitions1, definitions2)
    } catch let error as Experimental.StylePropertySupportDefinitions.MergingError {
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
    let definitions = Experimental.StylePropertySupportDefinitions {
      ("property1", type: .specific(Double.self))
    }
    let (validProperties, validationResults) = definitions.process([
      Experimental.StyleProperty(key: "property1", value: 1.0)
    ])
    XCTAssertEqual(validProperties.count, 1)
  }

  static var allTests = [
    ("testMerging", testMerging),
    ("testValidationAndFiltering", testValidationAndFiltering)
  ]
}