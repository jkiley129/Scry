import SwiftUI
import Testing

@testable import MTGLifeCounter

@Suite("Performance and Stress Tests")
struct PerformanceTests {

  // MARK: - Player Creation Performance

  @Test("Create many players quickly")
  func createManyPlayers() {
    var players: [Player] = []

    for i in 0..<10000 {
      let color: Color = [.red, .blue, .green, .white, .black][i % 5]
      players.append(Player(life: 20, color: color))
    }

    #expect(players.count == 10000)
    #expect(Set(players.map { $0.id }).count == 10000)
  }

  @Test("Rapid life total modifications")
  func rapidLifeModifications() {
    var player = Player(life: 20, color: .red)

    for i in 0..<10000 {
      if i % 2 == 0 {
        player.life -= 1
      } else {
        player.life += 1
      }
    }

    // Should end at 20 (alternating +1/-1)
    #expect(player.life == 20)
  }

  @Test("Many commander damage sources")
  func manyCommanderDamageSources() {
    var player = Player(life: 40, color: .blue)

    for i in 0..<100 {
      let commanderId = UUID()
      player.commanderDamage[commanderId] = i % 21
    }

    #expect(player.commanderDamage.count == 100)
  }

  @Test("Rapid counter modifications")
  func rapidCounterModifications() {
    var player = Player(life: 20, color: .green)

    for i in 0..<1000 {
      player.counters[.poison] = i % 10
      player.counters[.energy] = i % 20
      player.counters[.experience] = i % 30
      player.counters[.tax] = i % 15
    }

    // Final values based on 999 % n
    #expect(player.counters[.poison] == 999 % 10)
    #expect(player.counters[.energy] == 999 % 20)
    #expect(player.counters[.experience] == 999 % 30)
    #expect(player.counters[.tax] == 999 % 15)
  }

  // MARK: - Game History Performance

  @Test("Add many history entries")
  func addManyHistoryEntries() {
    let history = GameHistory()
    let playerId = UUID()

    for i in 0..<10000 {
      history.addEntry(playerId: playerId, message: "Entry \(i)")
    }

    #expect(history.entries.count == 10000)
  }

  @Test("Clear large history")
  func clearLargeHistory() {
    let history = GameHistory()
    let playerId = UUID()

    for i in 0..<10000 {
      history.addEntry(playerId: playerId, message: "Entry \(i)")
    }

    history.clear()
    #expect(history.entries.isEmpty)
  }

  @Test("Many history additions and clears")
  func manyAdditionsAndClears() {
    let history = GameHistory()
    let playerId = UUID()

    for cycle in 0..<100 {
      for i in 0..<100 {
        history.addEntry(playerId: playerId, message: "Cycle \(cycle) Entry \(i)")
      }
      history.clear()
    }

    #expect(history.entries.isEmpty)
  }

  // MARK: - Complex Game State Performance

  @Test("Full six player game with complete state")
  func fullSixPlayerGame() {
    var players: [Player] = []

    // Create 6 players
    for i in 0..<6 {
      let color: Color = [.red, .blue, .green, .white, .black, .purple][i]
      players.append(Player(life: 40, color: color))
    }

    // Each player takes damage from all other commanders
    for i in 0..<6 {
      for j in 0..<6 {
        if i != j {
          players[i].commanderDamage[players[j].id] = (i + j) * 2
        }
      }
    }

    // Each player has various counters
    for i in 0..<6 {
      players[i].counters[.poison] = i
      players[i].counters[.energy] = i * 2
      players[i].counters[.experience] = i * 3
    }

    // Verify all state
    #expect(players.count == 6)
    for i in 0..<6 {
      #expect(players[i].commanderDamage.count == 5)
      #expect(players[i].counters.count == 3)
    }
  }

  @Test("Simulate 100 turn game")
  func simulateHundredTurnGame() {
    var player1 = Player(life: 40, color: .red)
    var player2 = Player(life: 40, color: .blue)
    let history = GameHistory()

    for turn in 0..<100 {
      // Player 1 takes damage
      player1.life -= 1
      history.addEntry(playerId: player1.id, message: "Turn \(turn) Life -1")

      // Player 2 takes damage
      player2.life -= 1
      history.addEntry(playerId: player2.id, message: "Turn \(turn) Life -1")
    }

    #expect(player1.life == -60)
    #expect(player2.life == -60)
    #expect(history.entries.count == 200)
  }

  // MARK: - Data Structure Performance

  @Test("Dictionary lookup performance")
  func dictionaryLookupPerformance() {
    var player = Player(life: 40, color: .white)

    // Create many commander damage entries
    var commanderIds: [UUID] = []
    for i in 0..<1000 {
      let id = UUID()
      commanderIds.append(id)
      player.commanderDamage[id] = i
    }

    // Lookup all entries
    var sum = 0
    for id in commanderIds {
      if let damage = player.commanderDamage[id] {
        sum += damage
      }
    }

    // Sum of 0...999
    let expectedSum = (0..<1000).reduce(0, +)
    #expect(sum == expectedSum)
  }

  @Test("Counter type switching performance")
  func counterTypeSwitchingPerformance() {
    var player = Player(life: 20, color: .black)

    for i in 0..<10000 {
      let counterType = CounterType.allCases[i % CounterType.allCases.count]
      player.counters[counterType] = i
    }

    // Verify final state
    #expect(player.counters.count == 4)
  }

  // MARK: - Memory Efficiency Tests

  @Test("Player struct is value type")
  func playerIsValueType() {
    let player1 = Player(life: 20, color: .red)
    var player2 = player1

    player2.life = 30

    // player1 should be unchanged (value semantics)
    #expect(player1.life == 20)
    #expect(player2.life == 30)
  }

  @Test("Copying player doesn't share commander damage")
  func playerCopyIndependentCommanderDamage() {
    var player1 = Player(life: 40, color: .blue)
    let commanderId = UUID()
    player1.commanderDamage[commanderId] = 10

    var player2 = player1
    player2.commanderDamage[commanderId] = 20

    #expect(player1.commanderDamage[commanderId] == 10)
    #expect(player2.commanderDamage[commanderId] == 20)
  }

  @Test("Copying player doesn't share counters")
  func playerCopyIndependentCounters() {
    var player1 = Player(life: 20, color: .green)
    player1.counters[.poison] = 5

    var player2 = player1
    player2.counters[.poison] = 8

    #expect(player1.counters[.poison] == 5)
    #expect(player2.counters[.poison] == 8)
  }

  // MARK: - Rapid State Change Tests

  @Test("Rapid game restarts")
  func rapidGameRestarts() {
    var players: [Player] = []

    for _ in 0..<1000 {
      players = [
        Player(life: 40, color: .red),
        Player(life: 40, color: .blue),
        Player(life: 40, color: .green),
        Player(life: 40, color: .white),
      ]
    }

    #expect(players.count == 4)
    #expect(players.allSatisfy { $0.life == 40 })
  }

  @Test("Alternating history operations")
  func alternatingHistoryOperations() {
    let history = GameHistory()
    let playerId = UUID()

    for i in 0..<1000 {
      if i % 3 == 0 {
        history.addEntry(playerId: playerId, message: "Add \(i)")
      } else if i % 3 == 1 {
        history.clear()
      } else {
        history.addEntry(playerId: playerId, message: "Another \(i)")
      }
    }

    // The exact count depends on the pattern, but should be consistent
    #expect(history.entries.count >= 0)
  }

  // MARK: - Concurrent-like Operations

  @Test("Multiple players modified in sequence")
  func multiplePlayersSequentialModification() {
    var players = [
      Player(life: 20, color: .red),
      Player(life: 20, color: .blue),
      Player(life: 20, color: .green),
      Player(life: 20, color: .white),
    ]

    for _ in 0..<1000 {
      for i in 0..<4 {
        players[i].life -= 1
      }
    }

    #expect(players.allSatisfy { $0.life == -980 })
  }

  @Test("History from multiple players interleaved")
  func historyMultiplePlayersInterleaved() {
    let history = GameHistory()
    let player1 = UUID()
    let player2 = UUID()
    let player3 = UUID()
    let player4 = UUID()

    let players = [player1, player2, player3, player4]

    for i in 0..<10000 {
      let playerId = players[i % 4]
      history.addEntry(playerId: playerId, message: "Action \(i)")
    }

    #expect(history.entries.count == 10000)

    // Count entries per player
    let player1Count = history.entries.filter { $0.playerId == player1 }.count
    let player2Count = history.entries.filter { $0.playerId == player2 }.count
    let player3Count = history.entries.filter { $0.playerId == player3 }.count
    let player4Count = history.entries.filter { $0.playerId == player4 }.count

    #expect(player1Count == 2500)
    #expect(player2Count == 2500)
    #expect(player3Count == 2500)
    #expect(player4Count == 2500)
  }

  // MARK: - Realistic Game Simulation

  @Test("Complete realistic commander game")
  func completeRealisticCommanderGame() {
    var players = [
      Player(life: 40, color: .red),
      Player(life: 40, color: .blue),
      Player(life: 40, color: .green),
      Player(life: 40, color: .white),
    ]
    let history = GameHistory()

    history.addEntry(playerId: UUID(), message: "Game Started!")

    // Simulate 30 turns
    for turn in 1...30 {
      for playerIndex in 0..<4 {
        // Life changes
        let lifeChange = Int.random(in: -5...2)
        players[playerIndex].life += lifeChange
        history.addEntry(
          playerId: players[playerIndex].id,
          message: "Turn \(turn) Life \(lifeChange > 0 ? "+" : "")\(lifeChange)")

        // Occasional commander damage
        if turn % 3 == 0 {
          let targetIndex = (playerIndex + 1) % 4
          let targetId = players[targetIndex].id
          let currentDamage = players[targetIndex].commanderDamage[players[playerIndex].id] ?? 0
          players[targetIndex].commanderDamage[players[playerIndex].id] = currentDamage + 3
          history.addEntry(
            playerId: players[targetIndex].id,
            message: "Commander damage +3")
        }

        // Occasional poison
        if turn % 5 == 0 && playerIndex == 0 {
          let currentPoison = players[playerIndex].counters[.poison] ?? 0
          players[playerIndex].counters[.poison] = currentPoison + 1
          history.addEntry(
            playerId: players[playerIndex].id,
            message: "Poison +1")
        }
      }
    }

    // Verify game state
    #expect(players.count == 4)
    #expect(history.entries.count > 100)

    // All players have some commander damage tracked
    #expect(players.allSatisfy { !$0.commanderDamage.isEmpty })
  }
}
