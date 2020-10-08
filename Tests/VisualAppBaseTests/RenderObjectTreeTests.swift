import XCTest
@testable import VisualAppBase

final class RenderObjectTreeTests: XCTestCase {

    func makeTestTree() -> RenderObjectTree {

        RenderObjectTree {

            ContainerRenderObject {

            }
        }
    }

    func testBusPropagation() {

        let tree = makeTestTree()

        let bus = RenderObject.Bus()

        tree.bus = bus

        var messageBuffer = [RenderObject.UpwardMessage]()

        _ = bus.onUpwardMessage {

            messageBuffer.append($0)
        }

        tree.children[0].appendChild(ContainerRenderObject {})

        XCTAssertEqual(messageBuffer[0].sender.individualHash, tree.children[0].individualHash)

        XCTAssertEqual(messageBuffer[0].content, RenderObject.UpwardMessageContent.ChildrenUpdated)
    }

    static var allTests = [

        ("testBusPropagation", testBusPropagation)
    ]
}