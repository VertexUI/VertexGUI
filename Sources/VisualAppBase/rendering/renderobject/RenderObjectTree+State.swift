extension RenderObjectTree {
    
    public struct State {

        public var activeTransitionCount = 0

        public var currentTick: UInt64 = 0 // ticks are something like steps in a simulation

        public var currentTimestamp: Double = 0 // seconds the tree is alive
    }
}