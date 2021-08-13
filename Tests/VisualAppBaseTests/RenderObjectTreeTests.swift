import GfxMath
import Foundation
import Events
@testable import XCTest

final class RenderObjectTreeTests: XCTestCase {
    private func makeTestTree() -> RenderObjectTree {
        RenderObjectTree {
            ContainerRenderObject {
                ContainerRenderObject {}
            }

            ContainerRenderObject {}
        }
    }

    /**
     When setting the bus object on the root node,
     does it propagate to the children?
     And do the message propagate properly?
     */
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

        XCTAssertEqual(messageBuffer[0].content, RenderObject.UpwardMessageContent.childrenUpdated)
    }

    /**
     When a new node is inserted into the tree,
     does it receive the bus instance from it's parents
     and do messages propagate properly?
     */
    func testBusRetention() {
        let tree = makeTestTree()

        let bus = RenderObject.Bus()

        tree.bus = bus

        tree.children[0].removeChildren()

        tree.children[0].appendChild(ContainerRenderObject {})

        let newNode = tree[TreePath(0, 0)]!

        XCTAssertTrue(newNode.bus === bus)

        var messageBuffer = [RenderObject.UpwardMessage]()

        _ = bus.onUpwardMessage {
            messageBuffer.append($0)
        }

        newNode.appendChild(ContainerRenderObject {})

        XCTAssertEqual(messageBuffer.count, 1)
    }

    /**
     Does the tick message propagate to the RenderObjects properly and do
     the onTick handlers inside of each RenderObject work?
     */
    func testRenderObjectOnTick() {
        let tree = makeTestTree()

        let bus = RenderObject.Bus()

        tree.bus = bus

        let testObject = RenderStyleRenderObject(fillColor: .black) {}

        tree.children[0].appendChild(testObject)

        var propagatedTick: Tick?

        _ = testObject.onTick {
            propagatedTick = $0
        }

        let tick = Tick(deltaTime: 10, totalTime: 100)

        bus.down(.Tick(tick: tick))

        XCTAssertEqual(tick, propagatedTick)
    }

    /**
     Do the transition messages of the RenderStyle RenderObject work correctly?
     */
    func testRenderStyleTransitionMessages() {
        let tree = makeTestTree()

        let bus = RenderObject.Bus()

        tree.bus = bus

        let testedNode = RenderStyleRenderObject(fill: TimedRenderValue(
            id: 0,

            startTimestamp: 10,

            duration: 1

        ) { _ in

            Fill.Color(Color.white)
        }) {}

        tree.children[0].appendChild(testedNode)

        var messageBuffer = [RenderObject.UpwardMessage]()

        var transitionCount = 0

        _ = bus.onUpwardMessage {
            messageBuffer.append($0)

            switch $0.withContent {
            case .transitionStarted:

                transitionCount += 1

            case .transitionEnded:

                transitionCount -= 1

            default:

                break
            }
        }

        bus.down(.Tick(tick: Tick(deltaTime: 5, totalTime: 10.5)))

        XCTAssertTrue(messageBuffer.contains {
            $0.content == RenderObject.UpwardMessageContent.transitionStarted
        })

        XCTAssertTrue(!messageBuffer.contains {
            $0.content == RenderObject.UpwardMessageContent.transitionEnded
        })

        XCTAssertEqual(transitionCount, 1)

        bus.down(.Tick(tick: Tick(deltaTime: 5, totalTime: 11.1)))

        bus.down(.Tick(tick: Tick(deltaTime: 1, totalTime: 11.2)))

        XCTAssertTrue(messageBuffer.contains {
            $0.content == RenderObject.UpwardMessageContent.transitionEnded
        })

        XCTAssertEqual(transitionCount, 0)
    }

    /**
     Test whether the correct messages are output when a RenderStyle RenderObject
     is deinitialized before a transition finishes.
     */
    func testRenderStyleTransitionDeinit() {
        var testedNode: RenderObject? = RenderStyleRenderObject(fill: TimedRenderValue(
            id: 0,

            startTimestamp: 10,

            duration: 1
        ) { _ in

            .Color(.white)

        }) {}

        var transitionCount = 0

        _ = testedNode!.bus.onUpwardMessage {
            switch $0.withContent {
            case .transitionStarted:

                transitionCount += 1

            case .transitionEnded:

                transitionCount -= 1

            default:

                break
            }
        }

        testedNode!.bus.down(.Tick(tick: Tick(deltaTime: 1, totalTime: 10)))

        XCTAssertEqual(transitionCount, 1)

        testedNode = nil

        XCTAssertEqual(transitionCount, 0)
    }

    static var allTests = [
        ("testBusPropagation", testBusPropagation),
        ("testBusRetention", testBusRetention),
        ("testRenderObjectOnTick", testRenderObjectOnTick),
        ("testRenderStyleTransitionMessages", testRenderStyleTransitionMessages),
        ("testRenderStyleTransitionDeinit", testRenderStyleTransitionDeinit),
    ]
}
