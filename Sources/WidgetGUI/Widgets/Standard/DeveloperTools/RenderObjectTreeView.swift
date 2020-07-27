import VisualAppBase
import CustomGraphicsMath

public class RenderObjectTreeView: MultiChildWidget {
    private struct Group {
        var parent: Widget?
        var children: [Widget] = []
    }
    
    private struct Line {
        var groups: [Group] = []
    }

    private var debuggingData: RenderObjectTreeRenderer.DebuggingData
    private var selectedObjectPath: TreePath?    
    private var onObjectSelected = EventHandlerManager<(RenderObject, TreePath)>()

    private var groupedChildren: [Line] = []

    public init(
        debuggingData: RenderObjectTreeRenderer.DebuggingData, 
        selectedObjectPath: TreePath?, 
        onObjectSelected objectSelectedHandler: EventHandlerManager<(RenderObject, TreePath)>.Handler?) {
            self.debuggingData = debuggingData
            self.selectedObjectPath = selectedObjectPath
            if let objectSelectedHandler = objectSelectedHandler {
                _ = self.onObjectSelected.addHandler(objectSelectedHandler)
            }
            super.init(children: debuggingData.sequence.map {
                Text("Sequence Item \($0.range)")
            })

            var children = [Widget]()
            var currentLineParentIndices = [-2]
            debuggingData.tree.traverseDepth { object, path, index, parentIndex in
                let child = Button(onClick: { _ in
                    try! self.onObjectSelected.invokeHandlers((object, path))
                }) {
                    if path == selectedObjectPath {
                        Text("NODE ID Selected!")
                    } else {
                        Text("NODE ID \(index) at PAT \(path)")
                    }
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
                /*if parentIndex != currentParentIndex {

                }*/
                print("BEFORE SET", groupedChildren[path.count].groups.count, path.count)

                groupedChildren[path.count].groups[groupedChildren[path.count].groups.count - 1].children.append(child)
                /*child.bounds.topLeft = DPoint2(nextX, nextY)
                nextX += child.bounds.size.width + spacing
                print("Child index", index, "Child Size", child.bounds.size, nextX)*/
            }
            self.children = children
            for child in children {
                child.parent = self
            }
    }

    override open func layout() throws {
        var spacing: Double = 30
        var nextX: Double = 0
        var nextY: Double = 0
        var maxX: Double = 0
        var currentLineHeight: Double = 0
        for i in 0..<groupedChildren.count {
            for j in 0..<groupedChildren[i].groups.count {
                for k in 0..<groupedChildren[i].groups[j].children.count {
                    var child = groupedChildren[i].groups[j].children[k]
                    child.constraints = constraints
                    try child.layout()
                    child.bounds.topLeft = DPoint2(nextX, nextY)
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

        bounds.size = DSize2(maxX, nextY + currentLineHeight)
    }

    override open func render(_ renderedChildren: [RenderObject?]) -> RenderObject? {
        /*var groups = debuggingData.groups.map {
            RenderObject.Text("WOW \($0.id)", config: TextConfig(
                fontConfig: FontConfig(
                    family: context!.defaultFontFamily,
                    size: 16,
                    weight: .Regular,
                    style: .Normal
                ),
                color: .Black,
                wrap: false
            ), topLeft: globalPosition)
        }*/
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

        print("LHAVE LINES!!!", lines)
        for line in lines {
            print(line.start, line.end)
        }

        return RenderObject.RenderStyle(fillColor: FixedRenderValue(Color.White)) {
            //[RenderObject.Rect(globalBounds)]

            RenderObject.RenderStyle(strokeWidth: 2, strokeColor: FixedRenderValue(.Black)) {
                lines
                /*RenderObject.Custom(id: 23) { renderer throws in
                    for line in lines {
                        try renderer.lineSegment(from: line.start, to: line.end)
                        try renderer.strokeColor(.Black)
                        try renderer.strokeWidth(5)
                        try renderer.stroke()
                    }
                }*/
            }

            renderedChildren
            //groups
        }
    }
}