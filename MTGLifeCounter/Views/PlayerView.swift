import SwiftUI

enum PlayerViewState {
  case life
  case commanderDamage
  case counters
}

struct PlayerView: View {
  @EnvironmentObject var gameHistory: GameHistory
  @Binding var player: Player
  let allPlayers: [Player]
  let isCommanderMode: Bool
  @ObservedObject var actionStack: ActionStack

  @State private var recentChange: Int = 0
  @State private var changeTimer: Timer?
  @State private var viewState: PlayerViewState = .life
  @State private var showNameEditor: Bool = false

  var body: some View {
    ZStack {
      player.swiftUIColor

      VStack(spacing: 0) {
        // Player Name Header
        Button(action: { showNameEditor = true }) {
          Text(player.name)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.4))
            .cornerRadius(8)
        }
        .padding(.top, 8)
        
        // Content Area
        ZStack {
          switch viewState {
          case .life:
            lifeView
          case .commanderDamage:
            commanderDamageView
          case .counters:
            countersView
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        // Tab Bar
        HStack {
          Spacer()
          tabButton(title: "Life", icon: "heart.fill", state: .life)
          if isCommanderMode {
            Spacer()
            tabButton(title: "Cmdr", icon: "shield.fill", state: .commanderDamage)
          }
          Spacer()
          tabButton(title: "Counters", icon: "plusminus.circle.fill", state: .counters)
          Spacer()
        }
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
      }
    }
    .alert("Edit Player Name", isPresented: $showNameEditor) {
      TextField("Name", text: $player.name)
      Button("Done") { }
    }
  }

  private func tabButton(title: String, icon: String, state: PlayerViewState) -> some View {
    Button(action: { viewState = state }) {
      VStack(spacing: 4) {
        Image(systemName: icon)
          .font(.system(size: 20))
        Text(title)
          .font(.system(size: 10, weight: .bold))
      }
      .foregroundColor(viewState == state ? .white : .white.opacity(0.5))
    }
  }

  // MARK: - Life View
  private var lifeView: some View {
    ZStack {
      HStack(spacing: 0) {
        // Left half: Subtract Life
        Button(action: { recordLifeChange(-1) }) {
          ZStack {
            Color.clear
            Image(systemName: "minus.circle.fill")
              .font(.system(size: 60))
              .foregroundColor(.black.opacity(0.5))
              .padding(.trailing, 40)
            if recentChange < 0 {
              Text("\(recentChange)")
                .font(.system(size: 50, weight: .heavy))
                .foregroundColor(.black)
                .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 1)
                .padding(.trailing, 40)
                .offset(y: -60)
                .transition(.scale.combined(with: .opacity))
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .contentShape(Rectangle())
        }

        // Right half: Add Life
        Button(action: { recordLifeChange(1) }) {
          ZStack {
            Color.clear
            Image(systemName: "plus.circle.fill")
              .font(.system(size: 60))
              .foregroundColor(.black.opacity(0.5))
              .padding(.leading, 40)
            if recentChange > 0 {
              Text("+\(recentChange)")
                .font(.system(size: 50, weight: .heavy))
                .foregroundColor(.black)
                .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 1)
                .padding(.leading, 40)
                .offset(y: -60)
                .transition(.scale.combined(with: .opacity))
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .contentShape(Rectangle())
        }
      }

      Text("\(player.life)")
        .font(.system(size: 80, weight: .bold))
        .foregroundColor(.black)
        .allowsHitTesting(false)

      // Poison Indicator (if any)
      if let poison = player.counters[.poison], poison > 0 {
        VStack {
          Spacer()
          HStack {
            Spacer()
            HStack(spacing: 4) {
              Image(systemName: "skull")
              Text("\(poison)")
            }
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.green)
            .padding(8)
            .background(Color.black.opacity(0.6))
            .cornerRadius(12)
            .padding()
          }
        }
        .allowsHitTesting(false)
      }
    }
  }

  // MARK: - Commander Damage View
  private var commanderDamageView: some View {
    let opponents = allPlayers.filter { $0.id != player.id }
    return GeometryReader { geo in
      let cols = opponents.count > 3 ? 3 : max(opponents.count, 1)
      let rows = Int(ceil(Double(opponents.count) / Double(cols)))

      VStack(spacing: 8) {
        Text("Commander Damage")
          .font(.headline)
          .foregroundColor(.white)
          .padding(.top, 8)

        VStack(spacing: 8) {
          ForEach(0..<rows, id: \.self) { row in
            HStack(spacing: 8) {
              ForEach(0..<cols, id: \.self) { col in
                let index = row * cols + col
                if index < opponents.count {
                  let opponent = opponents[index]
                  commanderDamageCell(for: opponent)
                } else {
                  Color.clear
                }
              }
            }
          }
        }
        .padding(8)
      }
    }
  }

  private func commanderDamageCell(for opponent: Player) -> some View {
    let damage = player.commanderDamage[opponent.id] ?? 0
    return VStack(spacing: 4) {
      Text(opponent.name)
        .font(.system(size: 12, weight: .semibold))
        .foregroundColor(.white)
        .lineLimit(1)
      
      Text("\(damage)")
        .font(.system(size: 32, weight: .bold))
        .foregroundColor(damage >= 21 ? .red : .black)
      
      HStack {
        Button(action: { changeCommanderDamage(for: opponent.id, by: -1) }) {
          Image(systemName: "minus.circle.fill")
            .font(.title2)
            .foregroundColor(.black.opacity(0.6))
        }
        Button(action: { changeCommanderDamage(for: opponent.id, by: 1) }) {
          Image(systemName: "plus.circle.fill")
            .font(.title2)
            .foregroundColor(.black.opacity(0.6))
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(opponent.swiftUIColor.opacity(0.8))
    .cornerRadius(12)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(damage >= 21 ? Color.red : Color.white, lineWidth: damage >= 21 ? 4 : 2)
    )
  }

  // MARK: - Counters View
  private var countersView: some View {
    VStack(spacing: 8) {
      Text("Counters")
        .font(.headline)
        .foregroundColor(.white)
        .padding(.top, 8)

      ScrollView {
        VStack(spacing: 12) {
          counterRow(type: .poison, icon: "skull", color: .green)
          counterRow(type: .energy, icon: "bolt.fill", color: .yellow)
          counterRow(type: .experience, icon: "star.fill", color: .orange)
          counterRow(type: .tax, icon: "dollarsign.circle.fill", color: .gray)
        }
        .padding(12)
      }
    }
  }

  private func counterRow(type: CounterType, icon: String, color: Color) -> some View {
    let count = player.counters[type] ?? 0
    return HStack {
      Image(systemName: icon)
        .foregroundColor(color)
        .font(.title)
        .frame(width: 40)
      Text(type.rawValue.capitalized)
        .font(.headline)
        .foregroundColor(.white)
      Spacer()
      HStack(spacing: 20) {
        Button(action: { changeCounter(type: type, by: -1) }) {
          Image(systemName: "minus.circle.fill")
            .font(.title)
            .foregroundColor(.white.opacity(0.8))
        }
        Text("\(count)")
          .font(.title2)
          .bold()
          .foregroundColor(.white)
          .frame(width: 40)
        Button(action: { changeCounter(type: type, by: 1) }) {
          Image(systemName: "plus.circle.fill")
            .font(.title)
            .foregroundColor(.white.opacity(0.8))
        }
      }
    }
    .padding()
    .background(Color.white.opacity(0.1))
    .cornerRadius(12)
  }

  // MARK: - Actions

  private func recordLifeChange(_ amount: Int) {
    changeTimer?.invalidate()
    
    let previousLife = player.life
    player.life += amount
    
    // Record action for undo
    actionStack.addAction(.lifeChange(playerId: player.id, previousLife: previousLife, newLife: player.life))
    
    gameHistory.addEntry(
      playerId: player.id, message: "\(player.name): Life \(amount > 0 ? "+" : "")\(amount) (\(player.life))")

    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
      recentChange += amount
    }

    changeTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { _ in
      withAnimation(.easeOut(duration: 0.5)) {
        recentChange = 0
      }
    }
  }

  private func changeCommanderDamage(for opponentId: UUID, by amount: Int) {
    let current = player.commanderDamage[opponentId] ?? 0
    let newAmount = max(0, current + amount)
    
    // Record action for undo
    actionStack.addAction(.commanderDamageChange(playerId: player.id, opponentId: opponentId, previousDamage: current == 0 ? nil : current, newDamage: newAmount == 0 ? nil : newAmount))
    
    player.commanderDamage[opponentId] = newAmount

    gameHistory.addEntry(
      playerId: player.id, message: "\(player.name): Cmdr Dmg \(amount > 0 ? "+" : "")\(amount) (\(newAmount))")
  }

  private func changeCounter(type: CounterType, by amount: Int) {
    let current = player.counters[type] ?? 0
    let newAmount = max(0, current + amount)
    
    // Record action for undo
    actionStack.addAction(.counterChange(playerId: player.id, counterType: type, previousValue: current == 0 ? nil : current, newValue: newAmount == 0 ? nil : newAmount))
    
    player.counters[type] = newAmount

    gameHistory.addEntry(
      playerId: player.id,
      message: "\(player.name): \(type.rawValue.capitalized) \(amount > 0 ? "+" : "")\(amount) (\(newAmount))")
  }
}
