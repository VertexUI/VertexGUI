    import XCTest
    @testable import VisualAppBase

    final class TreeTests: XCTestCase {

        func testTreePathComparison() {
            var path1 = TreePath([0, 1, 1])
            var path2 = TreePath([0, 1, 1, 2])
            XCTAssertTrue(path1 < path2)
            XCTAssertFalse(path1 > path2)
            XCTAssertTrue(path2 > path1)
            XCTAssertFalse(path2 < path1)
            XCTAssertFalse(path1 == path2)

            path1 = TreePath([1, 1, 0])
            path2 = TreePath([1, 1, 0])            
            XCTAssertTrue(path1 == path2)
            XCTAssertFalse(path1 < path2)
            XCTAssertFalse(path1 > path2)
        }

        func testTreeRangeContains() {
            var range = TreeRange()

            range.extend(with: TreePath([0, 1, 0]))
            XCTAssertTrue(range.contains(TreePath([])))
            XCTAssertTrue(range.contains(TreePath([0])))
            XCTAssertTrue(range.contains(TreePath([0, 1])))
            XCTAssertTrue(range.contains(TreePath([0, 1, 0])))
            XCTAssertTrue(range.contains(TreePath([0, 0, 0, 1])))
            XCTAssertFalse(range.contains(TreePath([0, 1, 1])))

            range = TreeRange(from: TreePath([1, 1, 0, 0]), to: TreePath([2, 1]))
            XCTAssertTrue(range.contains(TreePath([1, 2])))
            XCTAssertTrue(range.contains(TreePath([1, 3, 4, 1, 0])))
            XCTAssertTrue(range.contains(TreePath([2, 0, 1, 1])))
            XCTAssertTrue(range.contains(TreePath([1, 1, 0, 0])))
            XCTAssertTrue(range.contains(TreePath([2, 1])))
            XCTAssertFalse(range.contains(TreePath([2, 2])))
            XCTAssertFalse(range.contains(TreePath([1, 0, 0, 0])))

            range.extend(with: TreePath([1, 0, 0, 1]))
            XCTAssertTrue(range.contains(TreePath([1, 0, 0, 1])))
            XCTAssertTrue(range.contains(TreePath([1, 0, 0, 2])))
            XCTAssertTrue(range.contains(TreePath([1, 1, 0, 0])))
            XCTAssertTrue(range.contains(TreePath([2, 1])))
            XCTAssertFalse(range.contains(TreePath([2, 2])))
            XCTAssertFalse(range.contains(TreePath([0, 1, 1, 5])))
        }

        func testTreeSliceIteration() {

            var tree = RenderObjectTree([

                ContainerRenderObject {

                },

                ContainerRenderObject {

                }
            ])

            var slice = RenderObjectTree.TreeSlice(tree: tree, start: TreePath([]), end: TreePath([]))

            for node in slice.depthFirst {

            }
        }

        static var allTests = [
            ("testTreePathComparison", testTreePathComparison),
            ("testTreeRangeContains", testTreeRangeContains),
            ("testTreeRangeContains", testTreeRangeContains)
        ]
    }
