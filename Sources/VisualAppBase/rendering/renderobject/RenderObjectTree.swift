import Foundation

// TODO: maybe rename RenderObjectTree
public class RenderObjectTree: SubTreeRenderObject {

    public private(set) var state = State()

    public var idPaths = [UInt: TreePath]()

    override open var hasTimedRenderValue: Bool {

        return false
    }

    override open var debugDescription: String {

        "RenderObjectTree"
    }

    override open var individualHash: Int {

        return 0
    }

    //override internal var _context: RenderObject.Context? = RenderObject.Context()

    //public internal(set) var onUpdate = EventHandlerManager<Update>()

    public init(_ children: [RenderObject] = []) {

        self.idPaths = [:]

        super.init(children: children)

        self.idPaths = getIdPathsRecursively(self, TreePath(), [UInt: TreePath]())
    }

    public convenience init(@RenderObjectBuilder children childrenBuilder: () -> [RenderObject]) {

        self.init(childrenBuilder())
    }

    // TODO: maybe add setter...
    public subscript(path: TreePath) -> RenderObject? {

        if path.count == 0 {

            return self
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
        // TODO: maybe instead of wrapping in a container here, just add a protocol that RenderObjectTree (maybe rename to RenderObjectTree) and SubTreeRenderObject conform too
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
    /*public func replace(_ identifiedSubTree: IdentifiedSubTreeRenderObject) {

        //let identifiedPath = idPaths[identifiedSubTree.id]!

        var replacedIdentifiedSubTreePath: TreePath?
       
        var replacedIdentifiedSubTree: IdentifiedSubTreeRenderObject?
       
        var newTree: RenderObjectTree?

        var parents: [SubTreeRenderObject] = [self]
     
        var currentPath = TreePath()
       
        var replacedChildren: [[RenderObject]] = [[RenderObject]()]

        outer: while parents.count > 0 {
         
            let parentIndex = currentPath.count

            for i in replacedChildren[parentIndex].count..<parents[parentIndex].children.count {

                if
                    let currentIdentifiedTree = parents[parentIndex].children[i] as? IdentifiedSubTreeRenderObject,
               
                    currentIdentifiedTree.id == identifiedSubTree.id {
                 //   if currentIdentifiedTree.id == identifiedSubTree.id {
                
                        replacedIdentifiedSubTree = currentIdentifiedTree
                
                        replacedIdentifiedSubTreePath = currentPath/i
                   
                        replacedChildren[parentIndex].append(identifiedSubTree)
                 /*   } else {
                        parents.append(currentIdentifiedTree)
                        replacedChildren.append([RenderObject]())
                        currentPath = currentPath/i
                        continue outer
                    }*/
             
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
          
                replacedChildren[parentIndex - 1].append(newFinished)
                //parents[parentIndex - 1].children.append(newFinished)
         
            } else {
          
                newTree = newFinished as? RenderObjectTree
            }
        }

        guard let unwrappedNewTree = newTree else {
      
            fatalError("Could not generate a new tree in updated().")
        }

        if let unwrappedReplacedIdentifiedSubTree = replacedIdentifiedSubTree, let replacedPath = replacedIdentifiedSubTreePath {
       
            onUpdate.invokeHandlers(

                .Replace(path: replacedPath, old: unwrappedReplacedIdentifiedSubTree, new: identifiedSubTree))
        }
    }*/

    /// - Warnings: Unused, untested
    public func traverseDepth(onObject objectHandler: (_ object: RenderObject, _ path: TreePath, _ index: Int, _ parentIndex: Int) throws -> Void) rethrows {
      
        var currentPath = TreePath()
       
        var currentIndex = 0
       
        try objectHandler(self, currentPath, currentIndex, -1)
        /*if !(rootObject is SubTreeRenderObject) {
            objectHandler(rootObject, currentPath, currentIndex)
            return
        }*/

        var parents: [SubTreeRenderObject] = [self]
     
        var parentIndices: [Int] = [currentIndex]
      
        var visitedChildrenCounts: [Int] = [0]

        depthLoop: repeat {
          
            let currentParentListIndex = currentPath.count
            
            breadthLoop: for i in visitedChildrenCounts[currentParentListIndex]..<parents[currentParentListIndex].children.count {
          
                currentIndex += 1
            
                visitedChildrenCounts[currentParentListIndex] += 1
            
                // TODO: does this create two unnecessary copies?
                let child = parents[currentParentListIndex].children[i]
            
                if let subTree = child as? SubTreeRenderObject {
            
                    currentPath = currentPath/i
              
                    try objectHandler(subTree, currentPath, currentIndex, parentIndices[currentParentListIndex])
               
                    parents.append(subTree)
              
                    parentIndices.append(currentIndex)
               
                    visitedChildrenCounts.append(0)
                 
                    continue depthLoop
               
                } else {
             
                    try objectHandler(child, currentPath/i, currentIndex, parentIndices[currentParentListIndex])
                }
            }

            parents.popLast()
          
            parentIndices.popLast()
          
            currentPath.popLast()
          
            visitedChildrenCounts.popLast()
        
        } while parents.count > 0
    }

    /*private final func processBusMessage(_ message: RootwardMessage) {

        switch message.content {

        case .TransitionStarted:

            state.activeTransitionCount += 1

        case .TransitionEnded:

            state.activeTransitionCount -= 1

        default:

            break
        }
    }*/

    /// - Parameter timeStep: in seconds
    /*public final func tick(_ timeStep: Double) {

        state.currentTick += 1

        state.currentTimestamp += timeStep

        treeContext.leafwardBus.publish(.Tick)
    }*/
}

extension RenderObjectTree {

    public enum Update {

        case Replace(path: TreePath, old: RenderObject, new: RenderObject)
    }

    public struct TreeSlice {

        public let tree: RenderObjectTree

        public let startPath: TreePath

        public let endPath: TreePath

        public init(tree: RenderObjectTree, start: TreePath, end: TreePath) {

            self.tree = tree

            self.startPath = start

            self.endPath = end
        }

        /*public var depthFirst: DepthFirstTreeSliceSequence {

            DepthFirstTreeSliceSequence(self)
        }*/

        public func sequence() -> TreeSliceSequence {

            return TreeSliceSequence(self)
        }

        public subscript(_ path: TreePath) -> RenderObject? {

            tree[path]
        }
        
        public func contains(_ path: TreePath) -> Bool {

            var maxCompareCount = min(path.count, startPath.count)

            for i in 0..<maxCompareCount {

                if path[i] > startPath[i] {

                    break

                } else if path[i] < startPath[i] {

                    return false
                }/* else if path[i] == start[i] && i == maxCompareCount - 1 && path.count > start.count {
                    return false
                }*/
            }

            maxCompareCount = min(path.count, endPath.count)

            for i in 0..<maxCompareCount {

                if path[i] < endPath[i] {

                    break

                } else if path[i] > endPath[i] {

                    return false
                }/* else if path[i] == start[i] && i == maxCompareCount - 1 && path.count > end.count {
                    return false
                }*/
            }

            return true
        }
    }

    public struct TreeSliceSequence: Sequence {
        
        private let slice: TreeSlice

        public init(_ slice: TreeSlice) {

            self.slice = slice
        }

        public func makeIterator() -> DepthFirstTreeIterator {

            DepthFirstTreeIterator(slice.tree, start: slice.startPath, end: slice.endPath)
        }
    }

    public struct DepthFirstTreeSequence: Sequence {

        public let tree: RenderObjectTree

        public init(tree: RenderObjectTree) {
            
            self.tree = tree
        }

        public func makeIterator() -> DepthFirstTreeIterator {
            
            DepthFirstTreeIterator(tree, start: TreePath([]), end: TreePath([]))
        }
    }

    public struct DepthFirstTreeIterator: IteratorProtocol {

        public let tree: RenderObjectTree

        private var nextPath: TreePath

        private var ended = false

        public init(_ tree: RenderObjectTree, start: TreePath, end: TreePath) {

            self.tree = tree

            self.nextPath = start
        }

        mutating public func next() -> RenderObject? {

            // TODO: this algorithm can be optimized!!!

            if ended {

                return nil
            }

            let node = tree[nextPath]

            if let node = node {

                if node.children.count > 0 {

                    nextPath = nextPath/0

                } else if let parent = node.parent, parent.children.count > nextPath.last! + 1 {
                    
                    nextPath = nextPath + 1

                } else if nextPath.count > 0 {

                    // until find a parent that has children that have not been visited dropLast

                    var currentChildPath = nextPath.dropLast()

                    var currentParent = node.parent?.parent

                    while true {

                        if currentParent == nil {

                            ended = true
                            
                            break
                        }

                        if currentParent!.children.count > currentChildPath.last! + 1 {

                            currentChildPath = currentChildPath + 1

                            break

                        } else {
                            
                            currentChildPath = currentChildPath.dropLast()

                            currentParent = currentParent!.parent
                        }
                    }

                    nextPath = currentChildPath

                } else {
                    
                    ended = true
                }
            }

            return node
        }
    }
}