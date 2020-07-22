import Foundation

// TODO: maybe name RenderObjectTree
// TODO: maybe rename RenderTreeRoot
public struct RenderTree: SubTreeRenderObject {
    public var children: [RenderObject]
    
    public var idPaths = [UInt: TreePath]()

    public var hasTimedRenderValue: Bool {
        return false
    }

    public init(_ children: [RenderObject]) {
        self.children = children
        self.idPaths = getIdPathsRecursively(self, TreePath(), [UInt: TreePath]())
    }

    // TODO: maybe add setter...
    public subscript(path: TreePath) -> RenderObject? {
        if path.count == 0 {
            return nil
        }
        var checkChildren = children
        for i in 0..<path.count {
            let pathSegment = path[i]
            if let child = checkChildren.count > pathSegment ? checkChildren[pathSegment] : nil {
                if i + 1 == path.count {
                    return child
                } else {
                    switch child {
                    case let child as SubTreeRenderObject:
                        checkChildren = child.children 
                    default:
                        return nil
                    }
                }
            } else {
                return nil
            }
        }
        return nil
    }

    private func getIdPathsRecursively(_ renderObject: RenderObject, _ currentPath: TreePath, _ currentIdPaths: [UInt: TreePath]) -> [UInt: TreePath] {
        var updatedPaths = currentIdPaths
        if let renderObject = renderObject as? RenderObject.IdentifiedSubTree {
            updatedPaths[renderObject.id] = currentPath
        }
        if let renderObject = renderObject as? SubTreeRenderObject {
            for i in 0..<renderObject.children.count {
                updatedPaths = getIdPathsRecursively(renderObject.children[i], currentPath/i, updatedPaths)
            }
        }
        return updatedPaths
    }

    /// Fills self.idPaths with ids mapped to paths of IdentifiedSubTreeRenderObjects
    /// by recursively checking every child in self.children.
    /// Should probably only be called in init.
    /*mutating private func retrieveIdPaths(_ startRenderObject: RenderObject, _ startPath: TreePath) {
        idPaths = [UInt: TreePath]()
        var currentPath = TreePath([0])
        // TODO: maybe instead of wrapping in a container here, just add a protocol that RenderTree (maybe rename to RenderTreeRoot) and SubTreeRenderObject conform too
        var parents: [SubTreeRenderObject] = [.Container(children)]
        var checkChildren = children
        outer: while parents.count > 0 {
            if currentPath.last! < checkChildren.count {
                for i in currentPath.last!..<checkChildren.count {
                    currentPath = currentPath + 1 // assuming one path step per loop iteration
                    let child = checkChildren[i]
                    print("CHECK CHILD", child)
                    if let child = child as? IdentifiedSubTreeRenderObject {
                        print("----------------------------")
                        print("SUBTREE", child)
                        print("---------------------------")
                        idPaths[child.id] = currentPath
                    }
                    if let parent = child as? SubTreeRenderObject, parent.children.count > 0 {
                        parents.append(parent)
                        checkChildren = parent.children
                        currentPath = currentPath/0
                        //print("ADD PARENT", parent, currentPath)
                        continue outer
                    }
                }
            }
            print("AFTER GROING DOWN", currentPath, idPaths)

            parents.removeLast()
            //print("PATH BEFORE", currentPath)
            currentPath.removeLast()
            //print("PATH AFTER", currentPath)
            //sleep(5)
            
            if let lastPathSegment = currentPath.last, parents.count > 0 {
                print("WELL NOW CHECK", parents.last!.children.count, parents.count, lastPathSegment)
                if parents.last!.children.count > lastPathSegment + 1 {
                    //currentPath = TreePath(Array(currentPath.segments[0..<currentPath.count - 1]))/(lastPathSegment + 1)
                    currentPath = currentPath + 1
                    checkChildren = parents.last!.children
                    print("ADVANCE TO NEXT CHLID AFTER GOING DOWN FIRST")
                } else {
                    // TODO: this case should mean, go up another parent
                    checkChildren = []
                }
            } else {
                print("NOPE THERE IS NOTHING", parents.count, currentPath)
                break
            }
        }
    }*/

    /*public func replaceRecursively(_ renderObjects: [RenderObject], _ currentPath: TreePath, _ identifiedSubTree: IdentifiedSubTreeRenderObject) -> ([RenderObject], TreePath?) {
        //print("UPDATE RECURSIVELY", identifiedSubTree)
        var updatedRenderObjects = [RenderObject]()
        var updatePath: TreePath?
        for i in 0..<renderObjects.count {
            let renderObject = renderObjects[i]
            if let renderObject = renderObject as? IdentifiedSubTreeRenderObject {
                if renderObject.id == identifiedSubTree.id {
                    updatedRenderObjects.append(identifiedSubTree)
                    updatePath = currentPath/i
                    continue
                }
            }
            if var renderObject = renderObject as? SubTreeRenderObject {
                let (children, subUpdatePath) = replaceRecursively(renderObject.children, currentPath/i, identifiedSubTree)
                renderObject.children = children
                updatedRenderObjects.append(renderObject)
                if subUpdatePath != nil {
                    updatePath = subUpdatePath
                }
            } else {
                updatedRenderObjects.append(renderObject)
            }
        }
        return (updatedRenderObjects, updatePath)
    }*/
    public func updated(_ identifiedSubTree: IdentifiedSubTreeRenderObject) -> (updatedTree: RenderTree, updatedIdentifiedSubTreePath: TreePath) {
        //let identifiedPath = idPaths[identifiedSubTree.id]!

        var replacedIdentifiedSubTreePath: TreePath?
        var replacedIdentifiedSubTree: IdentifiedSubTreeRenderObject?
        var newTree: RenderTree?

        var parents: [SubTreeRenderObject] = [self]
        var currentPath = TreePath()
        var replacedChildren: [[RenderObject]] = [[RenderObject]()]

        outer: while parents.count > 0 {
            let parentIndex = currentPath.count

            for i in replacedChildren[parentIndex].count..<parents[parentIndex].children.count {

                if let currentIdentifiedTree = parents[parentIndex].children[i] as? IdentifiedSubTreeRenderObject {
                    replacedIdentifiedSubTree = currentIdentifiedTree
                    replacedIdentifiedSubTreePath = currentPath/i
                    replacedChildren[parentIndex].append(identifiedSubTree)

                } else if let newParent = parents[parentIndex].children[i] as? SubTreeRenderObject {
                    parents.append(newParent)
                    replacedChildren.append([RenderObject]())
                    currentPath = currentPath/i
                    continue outer

                } else {
                    replacedChildren[parentIndex].append(parents[parentIndex].children[i])
                }
            }

            parents[parentIndex].children = replacedChildren[parentIndex]
            let newFinished = parents.popLast()!
            currentPath = currentPath.dropLast()
            replacedChildren.popLast()
            if parents.count > 0 {
                parents[parentIndex - 1].children.append(newFinished)
            } else {
                newTree = newFinished as? RenderTree
            }
        }

        guard let unwrappedNewTree = newTree else {
            fatalError("Could not generate a new tree in updated().")
        }

        guard let unwrappedReplacedIdentifiedSubTree = replacedIdentifiedSubTree else {
            fatalError("No SubTree with same id was present.")
        }



        //let (replacedC updatePath) = replaceRecursively(children, TreePath([]), identifiedSubTree)
        return (unwrappedNewTree, replacedIdentifiedSubTreePath!)
    }
}