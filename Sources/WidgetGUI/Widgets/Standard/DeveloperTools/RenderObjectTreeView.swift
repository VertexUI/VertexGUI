import VisualAppBase
import CustomGraphicsMath

public class RenderObjectTreeView: Widget {
    private struct Group {
        weak var parent: Widget?
        var children: [Widget] = []
    }
    
    private struct Line {
        var groups: [Group] = []
    }

    private var debuggingData: RenderObjectTreeRenderer.DebuggingData
    private var selectedObjectPath: TreePath?    
    private var onObjectSelected = ThrowingEventHandlerManager<(RenderObject, TreePath)>()

    private var groupedChildren: [Line] = []

    public init(
        debuggingData: RenderObjectTreeRenderer.DebuggingData, 
        selectedObjectPath: TreePath?, 
        onObjectSelected objectSelectedHandler: ThrowingEventHandlerManager<(RenderObject, TreePath)>.Handler?) {
            self.debuggingData = debuggingData
            self.selectedObjectPath = selectedObjectPath
            if let objectSelectedHandler = objectSelectedHandler {
                _ = self.onObjectSelected.addHandler(objectSelectedHandler)
            }
            super.init()
    }
    
    override open func build() {
        var currentLineParentIndices = [-2]
        debuggingData.tree.traverseDepth { [unowned self] object, path, index, parentIndex in
            let child = Button {
                if path == selectedObjectPath {
                    return Text("NODE ID Selected!")
                } else {
                    return Text("NODE ID \(index) at PAT \(path)")
                }
            } onClick: { _ in
                try! onObjectSelected.invokeHandlers((object, path))
            }
            children.append(child)

            if groupedChildren.count <= path.count {
                groupedChildren.append(Line())
                currentLineParentIndices.append(parentIndex)
            }
            if currentLineParentIndices[path.count] != parentIndex {
                currentLineParentIndices[path.count] = parentIndex
                var parent: Widget?
                if path.count > 0 {
                    parent = groupedChildren[path.count - 1].groups.last?.children.last
                }
                groupedChildren[path.count].groups.append(Group(parent: parent))
            }

            groupedChildren[path.count].groups[groupedChildren[path.count].groups.count - 1].children.append(child)
        }
    }

    override open func performLayout(constraints: BoxConstraints) -> DSize2 {

        let spacing: Double = 30
        
        var nextX: Double = 0

        var nextY: Double = 0

        var maxX: Double = 0

        var currentLineHeight: Double = 0

        for i in 0..<groupedChildren.count {

            for j in 0..<groupedChildren[i].groups.count {

                for k in 0..<groupedChildren[i].groups[j].children.count {

                    let child = groupedChildren[i].groups[j].children[k]

                    child.layout(constraints: constraints)

                    child.position = DPoint2(nextX, nextY)

                    nextX += child.bounds.size.width + spacing

                    if child.bounds.size.height > currentLineHeight {

                        currentLineHeight = child.bounds.size.height
                    }
                }

                if nextX - spacing > maxX {

                    maxX = nextX - spacing
                }

                nextX += spacing * 4
            }

            nextX = 0

            nextY += currentLineHeight + spacing

            currentLineHeight = 0
        }

        return constraints.constrain(DSize2(maxX, nextY + currentLineHeight))
    }

    override open func renderContent() -> RenderObject? {
        var lines = [RenderObject.LineSegment]()

        for i in 0..<groupedChildren.count {
            for j in 0..<groupedChildren[i].groups.count {
                for k in 0..<groupedChildren[i].groups[j].children.count {
                    let child = groupedChildren[i].groups[j].children[k]
                    if let parent = groupedChildren[i].groups[j].parent {
                        lines.append(RenderObject.LineSegment(from: parent.globalBounds.center, to: child.globalBounds.center))
                    }
                }
            }
        }

        lines.reverse()

        return RenderObject.RenderStyle(fillColor: .White) {
            RenderObject.RenderStyle(strokeWidth: 2, strokeColor: FixedRenderValue(.Black)) {
                lines
            }
            children.map { $0.render() }
        }
    }
    
    override open func destroySelf() {
        groupedChildren = []
    }
}
