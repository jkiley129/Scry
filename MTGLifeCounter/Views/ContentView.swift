import SwiftUI

struct ContentView: View {
  @EnvironmentObject var gameHistory: GameHistory
  @StateObject private var actionStack = ActionStack()
  @StateObject private var gameTimer = GameTimer()
  
  @State private var players: [Player] = []
  @State private var numberOfPlayers: Int = 2
  @State private var showMenu: Bool = false
  @State private var showTools: Bool = false
  @State private var showHistory: Bool = false
  @State private var isCommanderMode: Bool = false
  @State private var gameStartTime: Date = Date()
  @State private var showResumeAlert: Bool = false
  @State private var savedGameState: GameState?

  private var gameOver: Bool {
    let activePlayers = players.prefix(numberOfPlayers)
    return activePlayers.contains { $0.life <= 0 }
  }

  private func restartGame() {
    let startingLife = isCommanderMode ? 40 : 20
    let defaultColors: [CodableColor] = [.red, .blue, .green, .orange, .purple, .pink]
    let defaultNames = ["Player 1", "Player 2", "Player 3", "Player 4", "Player 5", "Player 6"]

    var newPlayers: [Player] = []
    for i in 0..<numberOfPlayers {
      let color = (i < players.count) ? players[i].color : defaultColors[i % defaultColors.count]
      let name = (i < players.count && !players[i].name.isEmpty) ? players[i].name : defaultNames[i]
      newPlayers.append(Player(life: startingLife, name: name, color: color))
    }
    players = newPlayers
    gameHistory.clear()
    actionStack.clear()
    gameStartTime = Date()
    gameTimer.reset()
    gameTimer.start()
    gameHistory.addEntry(playerId: UUID(), message: "Game Started!")
    saveGameState()
  }
  
  private func saveGameState() {
    let state = GameState(
      players: players,
      numberOfPlayers: numberOfPlayers,
      isCommanderMode: isCommanderMode,
      gameStartTime: gameStartTime
    )
    state.save()
  }
  
  private func loadGameState() {
    guard let state = GameState.load() else { return }
    players = state.players
    numberOfPlayers = state.numberOfPlayers
    isCommanderMode = state.isCommanderMode
    gameStartTime = state.gameStartTime
    gameTimer.resume(from: gameStartTime)
  }
  
  private func performUndo() {
    guard let action = actionStack.undo() else { return }
    
    if let index = players.firstIndex(where: { $0.id == action.playerId }) {
      switch action {
      case .lifeChange(_, let previousLife, _):
        players[index].life = previousLife
        gameHistory.addEntry(playerId: action.playerId, message: "Undo: \(action.description)")
        
      case .counterChange(_, let counterType, let previousValue, _):
        players[index].counters[counterType] = previousValue
        gameHistory.addEntry(playerId: action.playerId, message: "Undo: \(action.description)")
        
      case .commanderDamageChange(_, let opponentId, let previousDamage, _):
        players[index].commanderDamage[opponentId] = previousDamage
        gameHistory.addEntry(playerId: action.playerId, message: "Undo: Commander damage")
      }
      saveGameState()
    }
  }

  var body: some View {
    GeometryReader { geo in
      ZStack {
        if gameOver {
          // Game Over Screen
          VStack(spacing: 40) {
            Text("GGs")
              .font(.system(size: 120, weight: .bold, design: .rounded))
              .foregroundColor(.black)
            
            // Show winner(s)
            let winners = players.prefix(numberOfPlayers).filter { $0.life > 0 }
            if !winners.isEmpty {
              VStack(spacing: 10) {
                Text("Winner\(winners.count > 1 ? "s" : ""):")
                  .font(.title2)
                  .foregroundColor(.black)
                
                ForEach(winners) { winner in
                  Text(winner.name)
                    .font(.title)
                    .foregroundColor(winner.swiftUIColor)
                }
              }
            }
            
            Text("Game Duration: \(gameTimer.formattedTime)")
              .font(.title3)
              .foregroundColor(.gray)

            Button(action: {
              restartGame()
            }) {
              Text("Restart Game")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(12)
            }
          }
          .frame(width: geo.size.width, height: geo.size.height)
          .background(Color.white)
        } else {
          // Game View
          gameView(geo: geo)

          // Timer Display (top center)
          VStack {
            HStack {
              Spacer()
              Text(gameTimer.formattedTime)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
              Spacer()
            }
            .padding(.top, 10)
            Spacer()
          }
          .allowsHitTesting(false)

          // Menu Button Overlay (centered)
          if !showMenu {
            VStack {
              Spacer()
              HStack(spacing: 15) {
                // Undo Button
                Button(action: performUndo) {
                  HexagonShape()
                    .fill(actionStack.canUndo ? Color.green : Color.gray.opacity(0.5))
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: "arrow.uturn.backward").foregroundColor(.white))
                }
                .disabled(!actionStack.canUndo)
                
                Button(action: { showTools = true }) {
                  HexagonShape()
                    .fill(Color.orange)
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: "dice.fill").foregroundColor(.white))
                }

                Button(action: { showMenu = true }) {
                  HexagonShape()
                    .fill(Color.blue)
                    .frame(width: 60, height: 60)
                    .overlay(
                      Text("Menu")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                    )
                }

                Button(action: { showHistory = true }) {
                  HexagonShape()
                    .fill(Color.purple)
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: "clock.fill").foregroundColor(.white))
                }
              }
              Spacer()
            }
          }
        }

        // Settings Menu Overlay
        if showMenu {
          SettingsMenuView(
            numberOfPlayers: $numberOfPlayers,
            showMenu: $showMenu,
            isCommanderMode: $isCommanderMode,
            players: $players,
            onPlayersChanged: {
              restartGame()
            }
          )
        }
      }
    }
    .edgesIgnoringSafeArea(.all)
    .sheet(isPresented: $showTools) {
      ToolsView()
    }
    .sheet(isPresented: $showHistory) {
      HistoryView()
    }
    .alert("Resume Game?", isPresented: $showResumeAlert) {
      Button("Resume") {
        loadGameState()
      }
      Button("New Game") {
        GameState.clear()
        restartGame()
      }
    } message: {
      Text("You have a saved game in progress. Would you like to resume?")
    }
    .onAppear {
      if players.isEmpty {
        if let _ = GameState.load() {
          showResumeAlert = true
        } else {
          restartGame()
        }
      }
    }
    .onChange(of: players) { _ in
      saveGameState()
    }
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
      saveGameState()
    }
  }

  @ViewBuilder
  private func gameView(geo: GeometryProxy) -> some View {
    let cols = (numberOfPlayers == 2 || numberOfPlayers == 1) ? 1 : 2
    let rows = Int(ceil(Double(numberOfPlayers) / Double(cols)))

    VStack(spacing: 6) {
      ForEach(0..<rows, id: \.self) { row in
        HStack(spacing: 6) {
          ForEach(0..<cols, id: \.self) { col in
            let index = row * cols + col
            if index < numberOfPlayers {
              let targetWidth = (geo.size.width - CGFloat(cols - 1) * 6) / CGFloat(cols)
              let targetHeight = (geo.size.height - CGFloat(rows - 1) * 6) / CGFloat(rows)
              let rotation: Double =
                numberOfPlayers == 1
                ? 0 : (numberOfPlayers == 2 ? (row == 0 ? 180.0 : 0.0) : (col == 0 ? 90.0 : -90.0))

              PlayerView(
                player: $players[index],
                allPlayers: players,
                isCommanderMode: isCommanderMode,
                actionStack: actionStack
              )
              .frame(
                width: (rotation == 90 || rotation == -90) ? targetHeight : targetWidth,
                height: (rotation == 90 || rotation == -90) ? targetWidth : targetHeight
              )
              .rotationEffect(.degrees(rotation))
              .frame(width: targetWidth, height: targetHeight)
            } else {
              Color.clear
            }
          }
        }
      }
    }
    .background(Color.black)
  }
}

#Preview {
  ContentView()
    .environmentObject(GameHistory())
}
