import SwiftUI

struct ContentView: View {
  @State private var players: [Player] = []
  @State private var numberOfPlayers: Int = 2
  @State private var showMenu: Bool = false
  @State private var isCommanderMode: Bool = false

  private var gameOver: Bool {
    let activePlayers = players.prefix(numberOfPlayers)
    return activePlayers.contains { $0.life <= 0 }
  }

  private func restartGame() {
    let startingLife = isCommanderMode ? 40 : 20
    let defaultColors: [Color] = [.white, .white, .white, .white]

    var newPlayers: [Player] = []
    for i in 0..<4 {
      let color = (i < players.count) ? players[i].color : defaultColors[i]
      newPlayers.append(Player(life: startingLife, color: color))
    }
    players = newPlayers
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

            Button(action: restartGame) {
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

          // Menu Button Overlay (centered)
          if !showMenu {
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
    .onAppear {
      if players.isEmpty {
        restartGame()
      }
    }
  }

  @ViewBuilder
  private func gameView(geo: GeometryProxy) -> some View {
    if players.count >= 4 {
      if numberOfPlayers == 2 {
        VStack(spacing: 0) {
          PlayerView(player: $players[0], rotation: 180)
            .frame(width: geo.size.width, height: geo.size.height / 2)

          Rectangle()
            .fill(Color.gray)
            .frame(height: 2)

          PlayerView(player: $players[1])
            .frame(width: geo.size.width, height: geo.size.height / 2)
        }
      } else {
        ZStack {
          VStack(spacing: 0) {
            HStack(spacing: 0) {
              PlayerView(player: $players[0], rotation: 90)
                .frame(width: geo.size.width / 2, height: geo.size.height / 2)

              PlayerView(player: $players[1], rotation: -90)
                .frame(width: geo.size.width / 2, height: geo.size.height / 2)
            }

            Rectangle()
              .fill(Color.black)
              .frame(height: 2)

            HStack(spacing: 0) {
              PlayerView(player: $players[2], rotation: 90)
                .frame(width: geo.size.width / 2, height: geo.size.height / 2)

              PlayerView(player: $players[3], rotation: -90)
                .frame(width: geo.size.width / 2, height: geo.size.height / 2)
            }
          }

          Rectangle()
            .fill(Color.black)
            .frame(width: 2)
            .frame(maxHeight: .infinity)
        }
      }
    }
  }
}

#Preview {
  ContentView()
}
