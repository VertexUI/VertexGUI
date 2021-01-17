import XCTest
@testable import WidgetGUI

class StyleSelectorTests: XCTestCase {
  func testPartParsing() {
    var part: StyleSelectorPart = ".class1"
    XCTAssertFalse(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, ["class1"])
    XCTAssertEqual(part.pseudoClasses, [])
    
    part = ".class1.class2"
    XCTAssertFalse(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, ["class1", "class2"])
    XCTAssertEqual(part.pseudoClasses, [])

    part = ""
    XCTAssertFalse(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, [])
    XCTAssertEqual(part.pseudoClasses, [])

    part = ":pseudoClass1"
    XCTAssertFalse(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, [])
    XCTAssertEqual(part.pseudoClasses, ["pseudoClass1"])

    part = ":pseudoClass1:pseudoClass2"
    XCTAssertFalse(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, [])
    XCTAssertEqual(part.pseudoClasses, ["pseudoClass1", "pseudoClass2"])

    part = ":pseudoClass1.class1"
    XCTAssertFalse(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.pseudoClasses, ["pseudoClass1"])
    XCTAssertEqual(part.classes, ["class1"])

    part = "&.class1:pseudoClass1.class2"
    XCTAssertTrue(part.extendsParent)
    XCTAssertNil(part.typeName)
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, ["class1", "class2"])
    XCTAssertEqual(part.pseudoClasses, ["pseudoClass1"])

    part = "&MockLeafWidget"
    XCTAssertTrue(part.extendsParent)
    XCTAssertEqual(part.typeName, "MockLeafWidget")
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, [])
    XCTAssertEqual(part.pseudoClasses, [])

    part = "MockLeafWidget"
    XCTAssertFalse(part.extendsParent)
    XCTAssertEqual(part.typeName, "MockLeafWidget")
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, [])
    XCTAssertEqual(part.pseudoClasses, [])

    part = "MockLeafWidget.class-1"
    XCTAssertFalse(part.extendsParent)
    XCTAssertEqual(part.typeName, "MockLeafWidget")
    XCTAssertNil(part.type)
    XCTAssertEqual(part.classes, ["class-1"])
    XCTAssertEqual(part.pseudoClasses, [])

    part = ".class-1<"
    XCTAssertTrue(part.opensScope)

    part = "&<"
    XCTAssertTrue(part.opensScope)
  }

  func testParsing() {
    let selector: StyleSelector = "&.class1 .class2< Type1.class3:pseudoClass1"
    let parts: [StyleSelectorPart] = ["&.class1", ".class2<", "Type1.class3:pseudoClass1"]
    XCTAssertEqual(selector.parts, parts)
  }

  func testComparison() {
    let selector1: StyleSelector = "&.class-1:pseudoClass-1"
    let selector2: StyleSelector = "&.class-1:pseudoClass-1"
    XCTAssertEqual(selector1, selector2)

    let selector3: StyleSelector = "&.class-1"
    XCTAssertNotEqual(selector1, selector3)

    let selector4: StyleSelector = "&.class-1:pseudoClass-1 &:pseudoClass-2"
    XCTAssertNotEqual(selector1, selector4)

    let selector5: StyleSelector = "&.class-1:pseudoClass-1 &:pseudoClass-2"
    XCTAssertEqual(selector4, selector5)

    let selector6: StyleSelector = "&Type1.class-1:pseudoClass-1 &:pseudoClass-2"
    XCTAssertNotEqual(selector5, selector6)

    let selector7: StyleSelector = "&Type1.class-1:pseudoClass-1 &:pseudoClass-2"
    XCTAssertEqual(selector6, selector7)

    let selector8: StyleSelector = "&Type1.class-1:pseudoClass-1 &:pseudoClass-2 &"
    XCTAssertEqual(selector7, selector8)

    let selector9: StyleSelector = ""
    let selector10: StyleSelector = ""
    XCTAssertEqual(selector9, selector10)

    let selector11: StyleSelector = ":pseudoClass-1"
    let selector12: StyleSelector = ":pseudoClass-1"
    let selector13: StyleSelector = ""
    XCTAssertEqual(selector11, selector12)
    XCTAssertNotEqual(selector11, selector13)

    let selector14: StyleSelector = "&"
    let selector15: StyleSelector = "&"
    let selector16: StyleSelector = ""
    XCTAssertEqual(selector14, selector15)
    XCTAssertNotEqual(selector14, selector16)

    let selector17: StyleSelector = ".class-1"
    let selector18: StyleSelector = ".class-1"
    let selector19: StyleSelector = ""
    let selector20: StyleSelector = ":pseudoClass-1"
    XCTAssertEqual(selector17, selector18)
    XCTAssertNotEqual(selector17, selector19)
    XCTAssertNotEqual(selector17, selector20)

    let selector21: StyleSelector = "Type1"
    let selector22: StyleSelector = "Type1"
    let selector23: StyleSelector = ""
    let selector24: StyleSelector = "&Type1"
    let selector25: StyleSelector = "Type2"
    let selector26: StyleSelector = "Type2.class-1"
    XCTAssertEqual(selector21, selector22)
    XCTAssertNotEqual(selector21, selector23)
    XCTAssertNotEqual(selector21, selector24)
    XCTAssertNotEqual(selector21, selector25)
    XCTAssertNotEqual(selector25, selector26)

    let selector27: StyleSelector = "&< .class-1<"
    let selector28: StyleSelector = "&< .class-1<"
    let selector29: StyleSelector = "& .class-1<"
    XCTAssertEqual(selector27, selector28)
    XCTAssertNotEqual(selector27, selector29)
  }

  func testSimplification() {
    let selector1 = StyleSelector("&.class-1 &.class-2:pseudo-class-1 .class-1 &")
    let selector2 = StyleSelector("&.class-1.class-2:pseudo-class-1 .class-1")
    let selector3 = StyleSelector(["&.class-1.class-2:pseudo-class-1", ".class-1"])

    XCTAssertEqual(selector1, selector2)
    XCTAssertEqual(selector1, selector3)

    let selector4 = StyleSelector("&< &< .class-1 &<")
    let selector5 = StyleSelector(["&<", ".class-1<"])
    XCTAssertEqual(selector4, selector5)
  }

  static var allTests = [
    ("testPartParsing", testPartParsing),
    ("testParsing", testParsing),
    ("testComparison", testComparison),
    ("testSimplification", testSimplification)
  ]
}