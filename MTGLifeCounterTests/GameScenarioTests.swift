import SwiftUI
import Testing

@testable import MTGLifeCounter

@Suite("Game Scenario Integration Tests")
struct GameScenarioTests {

  // MARK: - Standard Game Scenarios

  @Test("Complete standard 1v1 game scenario")
  func standardOneVersusOneGame() {
    var player1 = Player(life: 20, color: .red)
    var player2 = Player(life: 20, color: .blue)
    let history = GameHistory()

    // Turn 1: Player 1 takes damage
    player1.life -= 3
    history.addEntry(playerId: player1.id, message: "Life -3 (17)")
    #expect(player1.life == 17)

    // Turn 2: Player 2 takes damage
    player2.life -= 5
    history.addEntry(playerId: player2.id, message: "Life -5 (15)")
    #expect(player2.life == 15)

    // Turn 3: Player 1 gains life
    player1.life += 4
    history.addEntry(playerId: player1.id, message: "Life +4 (21)")
    #expect(player1.life == 21)

    // Turn 4: Player 2 takes lethal damage
    player2.life -= 15
    history.addEntry(playerId: player2.id, message: "Life -15 (0)")
    #expect(player2.life == 0)

    // Verify history
    #expect(history.entries.count == 4)
  }

  @Test("Poison counter win scenario")
  func poisonCounterWin() throws {
    var player = Player(life: 20, color: .green)
    let history = GameHistory()

    // Progressive poison counters
    for i in 1...10 {
      player.counters[.poison] = i
      history.addEntry(playerId: player.id, message: "Poison +1 (\(i))")
    }

    let poisonCount = try #require(player.counters[.poison])
    #expect(poisonCount == 10)
    #expect(history.entries.count == 10)
  }

  @Test("Commander damage lethal scenario")
  func commanderDamageLethal() throws {
    var player = Player(life: 40, color: .white)
    let commanderId = UUID()
    let history = GameHistory()

    // Commander attacks multiple times
    let attacks = [5, 8, 9]  // Total: 22
    var totalDamage = 0

    for damage in attacks {
      totalDamage += damage
      player.commanderDamage[commanderId] = totalDamage
      history.addEntry(
        playerId: player.id, message: "Cmdr Dmg +\(damage) (\(totalDamage))")
    }

    let commanderDmg = try #require(player.commanderDamage[commanderId])
    #expect(commanderDmg == 22)
    #expect(commanderDmg >= 21)
    #expect(history.entries.count == 3)
  }

  // MARK: - Commander Game Scenarios

  @Test("Four player commander game setup")
  func fourPlayerCommanderSetup() {
    let players = [
      Player(life: 40, color: .red),
      Player(life: 40, color: .blue),
      Player(life: 40, color: .green),
      Player(life: 40, color: .white),
    ]

    #expect(players.count == 4)
    #expect(players.allSatisfy { $0.life == 40 })
  }

  @Test("Commander multiplayer with different damage sources")
  func commanderMultiplayerDamage() {
    var player = Player(life: 40, color: .black)
    let commander1 = UUID()
    let commander2 = UUID()
    let commander3 = UUID()

    // Player takes damage from multiple commanders
    player.commanderDamage[commander1] = 15
    player.commanderDamage[commander2] = 12
    player.commanderDamage[commander3] = 8

    // Also takes regular damage
    player.life -= 10

    #expect(player.life == 30)
    #expect(player.commanderDamage[commander1] == 15)
    #expect(player.commanderDamage[commander2] == 12)
    #expect(player.commanderDamage[commander3] == 8)

    // Not lethal yet from any single commander
    #expect(player.commanderDamage.values.allSatisfy { $0 < 21 })
  }

  // MARK: - Complex Counter Scenarios

  @Test("Energy counter accumulation scenario")
  func energyCounterAccumulation() throws {
    var player = Player(life: 20, color: .blue)
    let history = GameHistory()

    // Generate energy over multiple turns
    let energyGains = [3, 2, 4, 1, 5]
    var totalEnergy = 0

    for gain in energyGains {
      totalEnergy += gain
      player.counters[.energy] = totalEnergy
      history.addEntry(playerId: player.id, message: "Energy +\(gain) (\(totalEnergy))")
    }

    // Spend some energy
    totalEnergy -= 8
    player.counters[.energy] = totalEnergy
    history.addEntry(playerId: player.id, message: "Energy -8 (\(totalEnergy))")

    let finalEnergy = try #require(player.counters[.energy])
    #expect(finalEnergy == 7)
  }

  @Test("Experience counter progression")
  func experienceCounterProgression() throws {
    var player = Player(life: 40, color: .green)

    // Experience counters only increase, never decrease
    for i in 1...20 {
      player.counters[.experience] = i
    }

    let experience = try #require(player.counters[.experience])
    #expect(experience == 20)
  }

  @Test("Tax counter accumulation")
  func taxCounterAccumulation() throws {
    var player = Player(life: 40, color: .white)

    // Commander tax increases
    let taxIncreases = [2, 2, 2, 2]
    var totalTax = 0

    for increase in taxIncreases {
      totalTax += increase
      player.counters[.tax] = totalTax
    }

    let finalTax = try #require(player.counters[.tax])
    #expect(finalTax == 8)
  }

  @Test("Multiple counter types simultaneously")
  func multipleCounterTypes() {
    var player = Player(life: 20, color: .purple)

    player.counters[.poison] = 3
    player.counters[.energy] = 10
    player.counters[.experience] = 5
    player.counters[.tax] = 4

    #expect(player.counters[.poison] == 3)
    #expect(player.counters[.energy] == 10)
    #expect(player.counters[.experience] == 5)
    #expect(player.counters[.tax] == 4)

    // All counters are independent
    player.counters[.energy] = 0
    #expect(player.counters[.poison] == 3)
    #expect(player.counters[.energy] == 0)
  }

  // MARK: - Edge Case Scenarios

  @Test("Life total oscillation scenario")
  func lifeTotalOscillation() {
    var player = Player(life: 20, color: .red)

    // Life goes up and down
    player.life -= 10  // 10
    player.life += 15  // 25
    player.life -= 5   // 20
    player.life += 30  // 50
    player.life -= 40  // 10

    #expect(player.life == 10)
  }

  @Test("Near-death recovery scenario")
  func nearDeathRecovery() {
    var player = Player(life: 20, color: .white)

    // Player drops to 1 life
    player.life = 1
    #expect(player.life == 1)
    #expect(player.life > 0)

    // Player gains significant life
    player.life += 30
    #expect(player.life == 31)
  }

  @Test("Exactly lethal damage scenario")
  func exactlyLethalDamage() {
    var player = Player(life: 17, color: .black)

    player.life -= 17
    #expect(player.life == 0)
  }

  @Test("Overkill damage scenario")
  func overkillDamage() {
    var player = Player(life: 5, color: .green)

    player.life -= 20
    #expect(player.life == -15)
    #expect(player.life < 0)
  }

  @Test("Multiple win conditions triggered simultaneously")
  func multipleWinConditionsSimultaneous() throws {
    var player = Player(life: 1, color: .blue)
    let commanderId = UUID()

    // Player is at 1 life
    #expect(player.life == 1)

    // Takes lethal commander damage
    player.commanderDamage[commanderId] = 21

    // Gets 10th poison counter
    player.counters[.poison] = 10

    // Takes damage to go to 0 life
    player.life -= 1

    // All win conditions met
    #expect(player.life == 0)
    let cmdDmg = try #require(player.commanderDamage[commanderId])
    #expect(cmdDmg >= 21)
    let poison = try #require(player.counters[.poison])
    #expect(poison >= 10)
  }

  // MARK: - History Tracking Scenarios

  @Test("Game history tracks full game progression")
  func fullGameHistoryTracking() {
    let history = GameHistory()
    let player1 = UUID()
    let player2 = UUID()

    history.addEntry(playerId: UUID(), message: "Game Started!")
    history.addEntry(playerId: player1, message: "Life -3 (17)")
    history.addEntry(playerId: player2, message: "Life -2 (18)")
    history.addEntry(playerId: player1, message: "Poison +1 (1)")
    history.addEntry(playerId: player2, message: "Cmdr Dmg +5 (5)")
    history.addEntry(playerId: player1, message: "Life +4 (21)")

    #expect(history.entries.count == 6)
    #expect(history.entries.first?.message == "Life +4 (21)")
    #expect(history.entries.last?.message == "Game Started!")
  }

  @Test("History entries maintain chronological order")
  func historyChronologicalOrder() {
    let history = GameHistory()
    let playerId = UUID()

    let messages = [
      "Turn 1 action",
      "Turn 2 action",
      "Turn 3 action",
      "Turn 4 action",
    ]

    for message in messages {
      history.addEntry(playerId: playerId, message: message)
    }

    #expect(history.entries.count == 4)

    // Newest first (reverse order)
    #expect(history.entries[0].message == "Turn 4 action")
    #expect(history.entries[1].message == "Turn 3 action")
    #expect(history.entries[2].message == "Turn 2 action")
    #expect(history.entries[3].message == "Turn 1 action")
  }

  // MARK: - Game Reset Scenarios

  @Test("Game reset clears all state")
  func gameResetClearsState() {
    var player = Player(life: 5, color: .red)
    let commanderId = UUID()
    let history = GameHistory()

    // Player has various state
    player.life -= 15
    player.commanderDamage[commanderId] = 18
    player.counters[.poison] = 7
    player.counters[.energy] = 3

    history.addEntry(playerId: player.id, message: "Various actions")

    // Reset
    player = Player(life: 20, color: player.color)
    history.clear()

    #expect(player.life == 20)
    #expect(player.commanderDamage.isEmpty)
    #expect(player.counters.isEmpty)
    #expect(history.entries.isEmpty)
  }

  @Test("Game mode switch resets life totals")
  func gameModeSwitchResetsLife() {
    // Standard game
    var player = Player(life: 20, color: .blue)
    player.life -= 5

    // Switch to Commander
    player = Player(life: 40, color: player.color)
    #expect(player.life == 40)

    player.life -= 10

    // Switch back to Standard
    player = Player(life: 20, color: player.color)
    #expect(player.life == 20)
  }

  // MARK: - Six Player Game Scenarios

  @Test("Six player commander pod")
  func sixPlayerCommanderPod() {
    let players = [
      Player(life: 40, color: .red),
      Player(life: 40, color: .blue),
      Player(life: 40, color: .green),
      Player(life: 40, color: .white),
      Player(life: 40, color: .black),
      Player(life: 40, color: .purple),
    ]

    #expect(players.count == 6)
    #expect(players.allSatisfy { $0.life == 40 })

    // Verify all IDs are unique
    let ids = Set(players.map { $0.id })
    #expect(ids.count == 6)
  }

  @Test("Commander damage tracking with five opponents")
  func commanderDamageFiveOpponents() {
    var player = Player(life: 40, color: .red)

    let opponents = [UUID(), UUID(), UUID(), UUID(), UUID()]

    for (index, opponentId) in opponents.enumerated() {
      player.commanderDamage[opponentId] = (index + 1) * 4
    }

    #expect(player.commanderDamage.count == 5)
    #expect(player.commanderDamage[opponents[0]] == 4)
    #expect(player.commanderDamage[opponents[1]] == 8)
    #expect(player.commanderDamage[opponents[2]] == 12)
    #expect(player.commanderDamage[opponents[3]] == 16)
    #expect(player.commanderDamage[opponents[4]] == 20)
  }
}
