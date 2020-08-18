public class PlayerState {
    public var player: PlayerBlob

    public var foods = [UInt: FoodBlob]()

    public var otherPlayers = [UInt: PlayerBlob]()

    public init(player: PlayerBlob, foods: [FoodBlob], otherPlayers: [PlayerBlob]) {
        self.player = player
        for food in foods {
            self.foods[food.id] = food
        }
        for player in otherPlayers {
            self.otherPlayers[player.id] = player
        }
    }
}