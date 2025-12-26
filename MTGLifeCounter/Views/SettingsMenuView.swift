import SwiftUI

struct SettingsMenuView: View {
  @Binding var numberOfPlayers: Int
  @Binding var showMenu: Bool
  @Binding var isCommanderMode: Bool
  @Binding var players: [Player]
  let onPlayersChanged: () -> Void

  // Preset colors for quick selection
  let presetColors: [Color] = [
    .red, .blue, .green, .orange, .purple, .pink, .yellow, .gray, .black, .white,
  ]

  var body: some View {
    ZStack {
      Color.black.opacity(0.8)
        .ignoresSafeArea()
        .onTapGesture {
          showMenu = false
        }

      ScrollView {
        VStack(spacing: 30) {
          Text("Settings")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.white)

          // Number of Players
          VStack(spacing: 15) {
            Text("Number of Players")
              .font(.system(size: 18, weight: .semibold))
              .foregroundColor(.gray)

            HStack(spacing: 30) {
              Button(action: {
                numberOfPlayers = 2
                onPlayersChanged()
                // Keep menu open to adjust colors if desired, or close?
                // User flow: might want to set colors for new players.
                // But onPlayersChanged resets players.
              }) {
                Text("2")
                  .font(.system(size: 24, weight: .semibold))
                  .foregroundColor(numberOfPlayers == 2 ? .white : .gray)
                  .padding(.horizontal, 30)
                  .padding(.vertical, 12)
                  .background(numberOfPlayers == 2 ? Color.blue : Color.white.opacity(0.1))
                  .cornerRadius(12)
              }

              Button(action: {
                numberOfPlayers = 4
                onPlayersChanged()
              }) {
                Text("4")
                  .font(.system(size: 24, weight: .semibold))
                  .foregroundColor(numberOfPlayers == 4 ? .white : .gray)
                  .padding(.horizontal, 30)
                  .padding(.vertical, 12)
                  .background(numberOfPlayers == 4 ? Color.blue : Color.white.opacity(0.1))
                  .cornerRadius(12)
              }
            }
          }

          // Game Mode
          VStack(spacing: 15) {
            Text("Game Mode")
              .font(.system(size: 18, weight: .semibold))
              .foregroundColor(.gray)

            Button(action: {
              isCommanderMode.toggle()
              onPlayersChanged()
            }) {
              HStack(spacing: 15) {
                Text("Commander (40 Life)")
                  .font(.system(size: 20, weight: .medium))

                Image(systemName: isCommanderMode ? "checkmark.circle.fill" : "circle")
                  .font(.system(size: 24))
                  .foregroundColor(isCommanderMode ? .green : .gray)
              }
              .foregroundColor(.white)
              .padding(.horizontal, 20)
              .padding(.vertical, 12)
              .background(Color.white.opacity(0.1))
              .cornerRadius(12)
            }
          }

          // Player Colors
          VStack(spacing: 20) {
            Text("Player Colors")
              .font(.system(size: 18, weight: .semibold))
              .foregroundColor(.gray)

            ForEach(0..<min(numberOfPlayers, players.count), id: \.self) { index in
              VStack(alignment: .leading, spacing: 8) {
                Text("Player \(index + 1)")
                  .font(.system(size: 16, weight: .medium))
                  .foregroundColor(.white)

                ScrollView(.horizontal, showsIndicators: false) {
                  HStack(spacing: 12) {
                    ForEach(presetColors, id: \.self) { color in
                      Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .overlay(
                          Circle()
                            .stroke(Color.white, lineWidth: players[index].color == color ? 3 : 0)
                        )
                        .onTapGesture {
                          players[index].color = color
                        }
                    }

                    // Color Picker for custom colors
                    ColorPicker("", selection: $players[index].color)
                      .labelsHidden()
                  }
                }
              }
            }
          }

          Button(action: {
            showMenu = false
          }) {
            Text("Close")
              .font(.system(size: 18, weight: .semibold))
              .foregroundColor(.black)
              .padding(.horizontal, 40)
              .padding(.vertical, 12)
              .background(Color.white)
              .cornerRadius(25)
          }
          .padding(.top, 10)
        }
        .padding(30)
        .background(Color.gray.opacity(0.15))
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .padding(20)
      }
    }
  }
}
