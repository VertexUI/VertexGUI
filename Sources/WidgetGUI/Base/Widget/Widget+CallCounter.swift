import Foundation

extension Widget {

    internal struct CallCounter {

        private static let burstInterval = 0.001 // in seconds

        private static let burstLogThreshold = 3 // after which call count in the burst interval should a message be printed?

        public private(set) var counts = Self.makeDictionary(0)

        public private(set) var burstCounts = Self.makeDictionary(0)

        public private(set) var burstStartTimestamps = Self.makeDictionary(0.0)

        // TODO: does this cause a retain cycle?
        unowned public var widget: Widget

        mutating func count(_ callType: CallType) {

            counts[callType] += 1

            let currentTimestamp = Date.timeIntervalSinceReferenceDate

            let previousBurstStartTimestamp = burstStartTimestamps[callType]

            if currentTimestamp - previousBurstStartTimestamp < Self.burstInterval {

                burstCounts[callType] += 1

            } else {

                burstCounts[callType] = 1

                burstStartTimestamps[callType] = currentTimestamp
            }

            if burstCounts[callType] > Self.burstLogThreshold {

                Logger.log(LogText(stringLiteral: "\(callType) called \(burstCounts[callType]) times" +

                    " in \(Self.burstInterval) or less seconds in widget \(widget) with id \(widget.id)"),

                    level: .Message, context: .Performance)
            }
        }

        private static func makeDictionary<T>(_ initial: T) -> DefinitiveDictionary<CallType, T> {
            
            DefinitiveDictionary(

                CallType.allCases.reduce(into: [CallType: T]()) {

                    $0[$1] = initial
                }
            )
        }
    }

    internal enum CallType: CaseIterable {

        case Layout, Render, InvalidateRenderState, InvalidateLayout
    }
}


