import CustomGraphicsMath
import Foundation

public struct TwoDRaycast {
    public var gridSize: AnySize2<Int>
    public var rayStart: AnyVector2<Double>
    public var rayEnd: AnyVector2<Double>
    public var testedTiles: [AnyVector2<Int>]
    public var results: [Result]

    public struct Result {
        public var tileIndex: IVec2
        public var edge: Tile.Edge

        public init(_ tileIndex: IVec2, _ edge: Tile.Edge) {
            self.tileIndex = tileIndex
            self.edge = edge
        }
    }

    public init(gridSize: AnySize2<Int>, rayStart: AnyVector2<Double>, rayEnd: AnyVector2<Double>) {
        self.gridSize = gridSize
        self.rayStart = rayStart
        self.rayEnd = rayEnd
        self.testedTiles = []
        self.results = []
        calculate()
    }

    /*private func getTileLines(tileIndex index: IVec2) -> [AnyLine<DVec2>] {
        let tilePosition = DVec2(index)
        return [
            AnyLine(point: tilePosition, direction: DVec2(1, 0)),
            AnyLine(point: tilePosition + DVec2(1, 0), direction: DVec2(0, -1)),
            AnyLine(point: tilePosition + DVec2(1, 1), direction: DVec2(-1, 0)),
            AnyLine(point: tilePosition, direction: DVec2(0, -1)),
        ]
    }

    private func getTileSideVertices(_ index: IVec2, _ side: ) -> (DVec2, DVec2) {
        let tilePosition = DVec2(index)
        switch side {
        case .Top:
            return (tilePosition, tilePosition + DVec2(1, 0))
        case .Right:
            return (tilePosition + DVec2(1, 0), tilePosition + DVec2(1, 1))
        case .Bottom:
            return (tilePosition + DVec2(1, 1), tilePosition + DVec2(0, 1))
        case .Left:
            return (tilePosition, tilePosition + DVec2(0, 1))
        }
    }*/

    mutating private func calculate() {
        var path = rayEnd - rayStart
        var direction = path.normalized()
        var rayLine = AnyLine(point: rayStart, direction: direction)
        var drivingAxis = direction.abs().firstIndex(of: direction.abs().max()!)!
        var otherAxis = drivingAxis == 0 ? 1 : 0
        var targetSlope = direction[otherAxis] / direction[drivingAxis]
        
        var startIndex = rayStart.rounded(.down)
        var endIndex = rayEnd.rounded(.down)
        var currentOffset = DVec2()
        
        var testedOffsets = [DVec2]()
        
        while currentOffset.length < path.length {
            testedOffsets.append(currentOffset)

            /*for otherAxisOffset in -2...2 {
                var step = step
                step[otherAxis] += Double(otherAxisOffset)
                testedOffsets.append(currentOffset + step)
            }*/


            //var step = DVec2()
            //step[drivingAxis] = copysign(1, direction[drivingAxis])
            var nextOffset = currentOffset
            nextOffset[drivingAxis] += copysign(1, direction[drivingAxis])
            let slope = nextOffset[otherAxis] / nextOffset[drivingAxis]
            if abs(slope) - abs(targetSlope) < 1 {
                nextOffset[otherAxis] += copysign(1, direction[otherAxis])
            }

            currentOffset = nextOffset
        }

        for offset in testedOffsets {
            let tileIndex = IVec2(startIndex + offset.rounded(.down))
            testedTiles.append(tileIndex)
            
            //let lines = getTileLines(tileIndex: tileIndex)
            let edgeVertices = Tile.edgeVertices(topLeft: DVec2(tileIndex))
            for edge in Tile.Edge.allCases {
                let vertices = edgeVertices[edge]!
                let line = AnyLine(vertices.0, vertices.1)
                if let intersection = rayLine.intersect(line: line) {
                    if line.pointBetween(test: intersection, from: vertices.0, to: vertices.1) {
                        results.append(Result(tileIndex, edge))
                    }
                    break
                }
            }
        }
    }
}