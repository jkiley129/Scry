import SwiftUI
import Testing

@testable import MTGLifeCounter

@Suite("Edge Cases and Boundary Tests")
struct EdgeCaseTests {

  // MARK: - Life Total Edge Cases

  @Test("Very high life total")
  func veryHighLifeTotal() {
    var player = Player(life: 20, color: .white)
    player.life += 1000

    #expect(player.life == 1020)
  }

  @Test("Very negative life total")
  func veryNegativeLifeTotal() {
    var player = Player(life: 20, color: .black)
    player.life -= 1000

    #expect(player.life == -980)
  }

  @Test("Maximum integer life value")
  func maximumIntegerLife() {
    let player = Player(life: Int.max, color: .green)

    #expect(player.life == Int.max)
  }

  @Test("Minimum integer life value")
  func minimumIntegerLife() {
    let player = Player(life: Int.min, color: .red)

    #expect(player.life == Int.min)
  }

  @Test("Zero life is not positive")
  func zeroLifeIsNotPositive() {
    let player = Player(life: 0, color: .blue)

    #expect(player.life == 0)
    #expect(player.life <= 0)
    #expect(!(player.life > 0))
  }

  @Test("Life increments and decrements are precise")
  func lifePreciseIncrements() {
    var player = Player(life: 20, color: .white)

    for _ in 0..<100 {
      player.life += 1
    }
    #expect(player.life == 120)

    for _ in 0..<100 {
      player.life -= 1
    }
    #expect(player.life == 20)
  }

  // MARK: - Commander Damage Edge Cases

  @Test("Commander damage with zero value")
  func commanderDamageZero() {
    var player = Player(life: 40, color: .red)
    let commanderId = UUID()

    player.commanderDamage[commanderId] = 0
    #expect(player.commanderDamage[commanderId] == 0)
  }

  @Test("Commander damage removed by setting to zero")
  func removeCommanderDamage() {
    var player = Player(life: 40, color: .blue)
    let commanderId = UUID()

    player.commanderDamage[commanderId] = 15
    player.commanderDamage[commanderId] = 0

    #expect(player.commanderDamage[commanderId] == 0)
  }

  @Test("Commander damage exactly at lethal threshold")
  func commanderDamageExactlyLethal() throws {
    var player = Player(life: 40, color: .green)
    let commanderId = UUID()

    player.commanderDamage[commanderId] = 21
    let dmg = try #require(player.commanderDamage[commanderId])
    #expect(dmg == 21)
  }

  @Test("Commander damage well over threshold")
  func commanderDamageOverLethal() throws {
    var player = Player(life: 40, color: .white)
    let commanderId = UUID()

    player.commanderDamage[commanderId] = 50
    let dmg = try #require(player.commanderDamage[commanderId])
    #expect(dmg >= 21)
  }

  @Test("Commander damage from non-existent opponent")
  func commanderDamageNonExistentOpponent() {
    let player = Player(life: 40, color: .black)
    let randomId = UUID()

    #expect(player.commanderDamage[randomId] == nil)
  }

  @Test("Multiple commanders same damage value")
  func multipleCommandersSameDamage() {
    var player = Player(life: 40, color: .red)
    let commander1 = UUID()
    let commander2 = UUID()
    let commander3 = UUID()

    player.commanderDamage[commander1] = 10
    player.commanderDamage[commander2] = 10
    player.commanderDamage[commander3] = 10

    #expect(player.commanderDamage.count == 3)
    #expect(player.commanderDamage.values.allSatisfy { $0 == 10 })
  }

  // MARK: - Counter Edge Cases

  @Test("Poison counter at exactly lethal")
  func poisonCounterExactlyLethal() throws {
    var player = Player(life: 20, color: .green)
    player.counters[.poison] = 10

    let poison = try #require(player.counters[.poison])
    #expect(poison == 10)
  }

  @Test("Poison counter over lethal")
  func poisonCounterOverLethal() throws {
    var player = Player(life: 20, color: .black)
    player.counters[.poison] = 15

    let poison = try #require(player.counters[.poison])
    #expect(poison >= 10)
  }

  @Test("Poison counter removed")
  func poisonCounterRemoved() {
    var player = Player(life: 20, color: .white)

    player.counters[.poison] = 5
    player.counters[.poison] = 0

    #expect(player.counters[.poison] == 0)
  }

  @Test("Very high energy counter value")
  func veryHighEnergyCounter() {
    var player = Player(life: 20, color: .blue)
    player.counters[.energy] = 999

    #expect(player.counters[.energy] == 999)
  }

  @Test("Counter type set then deleted")
  func counterSetThenDeleted() {
    var player = Player(life: 20, color: .red)

    player.counters[.experience] = 10
    #expect(player.counters[.experience] == 10)

    player.counters[.experience] = nil
    #expect(player.counters[.experience] == nil)
  }

  @Test("All counter types at maximum safe values")
  func allCountersMaximum() {
    var player = Player(life: 20, color: .purple)

    player.counters[.poison] = 99
    player.counters[.energy] = 999
    player.counters[.experience] = 999
    player.counters[.tax] = 999

    #expect(player.counters[.poison] == 99)
    #expect(player.counters[.energy] == 999)
    #expect(player.counters[.experience] == 999)
    #expect(player.counters[.tax] == 999)
  }

  // MARK: - Game History Edge Cases

  @Test("Empty game history")
  func emptyGameHistory() {
    let history = GameHistory()
    #expect(history.entries.isEmpty)
    #expect(history.entries.count == 0)
  }

  @Test("Single entry in history")
  func singleHistoryEntry() {
    let history = GameHistory()
    let playerId = UUID()

    history.addEntry(playerId: playerId, message: "Single entry")

    #expect(history.entries.count == 1)
    #expect(history.entries.first?.message == "Single entry")
    #expect(history.entries.last?.message == "Single entry")
  }

  @Test("Very long game history")
  func veryLongGameHistory() {
    let history = GameHistory()
    let playerId = UUID()

    for i in 0..<1000 {
      history.addEntry(playerId: playerId, message: "Entry \(i)")
    }

    #expect(history.entries.count == 1000)
  }

  @Test("Game history with empty message")
  func gameHistoryEmptyMessage() {
    let history = GameHistory()
    let playerId = UUID()

    history.addEntry(playerId: playerId, message: "")

    #expect(history.entries.count == 1)
    #expect(history.entries.first?.message == "")
  }

  @Test("Game history with very long message")
  func gameHistoryLongMessage() {
    let history = GameHistory()
    let playerId = UUID()
    let longMessage = String(repeating: "A", count: 1000)

    history.addEntry(playerId: playerId, message: longMessage)

    #expect(history.entries.count == 1)
    #expect(history.entries.first?.message == longMessage)
  }

  @Test("Clearing empty game history")
  func clearEmptyHistory() {
    let history = GameHistory()

    history.clear()
    #expect(history.entries.isEmpty)
  }

  @Test("Adding after clearing history")
  func addAfterClearingHistory() {
    let history = GameHistory()
    let playerId = UUID()

    history.addEntry(playerId: playerId, message: "First")
    history.clear()
    history.addEntry(playerId: playerId, message: "After clear")

    #expect(history.entries.count == 1)
    #expect(history.entries.first?.message == "After clear")
  }

  @Test("Multiple clears in sequence")
  func multipleClears() {
    let history = GameHistory()
    let playerId = UUID()

    history.addEntry(playerId: playerId, message: "Entry")
    history.clear()
    history.clear()
    history.clear()

    #expect(history.entries.isEmpty)
  }

  // MARK: - Player Color Edge Cases

  @Test("All standard colors are valid")
  func allStandardColors() {
    let colors: [Color] = [.red, .blue, .green, .white, .black]

    for color in colors {
      let player = Player(life: 20, color: color)
      #expect(player.color == color)
    }
  }

  @Test("Custom colors are valid")
  func customColors() {
    let customColor = Color(red: 0.5, green: 0.3, blue: 0.7)
    let player = Player(life: 20, color: customColor)

    #expect(player.color == customColor)
  }

  @Test("Players can share same color")
  func playersShareColor() {
    let player1 = Player(life: 20, color: .red)
    let player2 = Player(life: 20, color: .red)

    #expect(player1.color == player2.color)
    #expect(player1.id != player2.id)
  }

  // MARK: - UUID Edge Cases

  @Test("Each player gets unique UUID")
  func eachPlayerUniqueUUID() {
    var ids = Set<UUID>()

    for _ in 0..<1000 {
      let player = Player(life: 20, color: .blue)
      ids.insert(player.id)
    }

    #expect(ids.count == 1000)
  }

  @Test("History entries get unique UUIDs")
  func historyEntriesUniqueUUID() {
    let history = GameHistory()
    let playerId = UUID()

    for i in 0..<100 {
      history.addEntry(playerId: playerId, message: "Entry \(i)")
    }

    let ids = Set(history.entries.map { $0.id })
    #expect(ids.count == 100)
  }

  // MARK: - State Consistency Tests

  @Test("Player state remains consistent after multiple operations")
  func playerStateConsistency() {
    var player = Player(life: 20, color: .green)
    let commanderId = UUID()

    // Multiple operations
    player.life -= 5
    player.counters[.poison] = 2
    player.commanderDamage[commanderId] = 10
    player.life += 3
    player.counters[.poison] = 3
    player.commanderDamage[commanderId] = 15

    // Verify final state
    #expect(player.life == 18)
    #expect(player.counters[.poison] == 3)
    #expect(player.commanderDamage[commanderId] == 15)
  }

  @Test("History and player state stay in sync")
  func historyPlayerSync() {
    var player = Player(life: 20, color: .red)
    let history = GameHistory()

    player.life -= 5
    history.addEntry(playerId: player.id, message: "Life -5 (15)")

    #expect(player.life == 15)
    #expect(history.entries.count == 1)

    player.life += 3
    history.addEntry(playerId: player.id, message: "Life +3 (18)")

    #expect(player.life == 18)
    #expect(history.entries.count == 2)
  }

  // MARK: - Counter Type Enumeration Tests

  @Test("Counter type iteration")
  func counterTypeIteration() {
    let allTypes = CounterType.allCases
    var countersDict: [CounterType: Int] = [:]

    for counterType in allTypes {
      countersDict[counterType] = 0
    }

    #expect(countersDict.count == 4)
    #expect(countersDict.keys.contains(.poison))
    #expect(countersDict.keys.contains(.energy))
    #expect(countersDict.keys.contains(.experience))
    #expect(countersDict.keys.contains(.tax))
  }

  @Test("Counter type ordering")
  func counterTypeOrdering() {
    let allCases = CounterType.allCases

    #expect(allCases.count == 4)
    // The order should be consistent
    #expect(allCases[0] == .poison)
    #expect(allCases[1] == .energy)
    #expect(allCases[2] == .experience)
    #expect(allCases[3] == .tax)
  }
}
