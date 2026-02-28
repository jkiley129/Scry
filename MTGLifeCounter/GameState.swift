import Foundation

struct GameState: Codable {
  var players: [Player]
  var numberOfPlayers: Int
  var isCommanderMode: Bool
  var gameStartTime: Date
  
  func save() {
    if let encoded = try? JSONEncoder().encode(self) {
      UserDefaults.standard.set(encoded, forKey: "SavedGameState")
    }
  }
  
  static func load() -> GameState? {
    guard let data = UserDefaults.standard.data(forKey: "SavedGameState"),
          let state = try? JSONDecoder().decode(GameState.self, from: data) else {
      return nil
    }
    return state
  }
  
  static func clear() {
    UserDefaults.standard.removeObject(forKey: "SavedGameState")
  }
}
