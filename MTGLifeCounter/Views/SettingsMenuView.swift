import SwiftUI

struct SettingsMenuView: View {
  @EnvironmentObject var gameHistory: GameHistory
  @Binding var numberOfPlayers: Int
  @Binding var showMenu: Bool
  @Binding var isCommanderMode: Bool
  @Binding var players: [Player]
  let onPlayersChanged: () -> Void

  // Preset colors for quick selection
  let presetColors: [CodableColor] = [
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

            HStack(spacing: 15) {
              ForEach([2, 4, 5, 6], id: \.self) { count in
                Button(action: {
                  numberOfPlayers = count
                  onPlayersChanged()
                }) {
                  Text("\(count)")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(numberOfPlayers == count ? .white : .gray)
                    .frame(minWidth: 44)
                    .padding(.vertical, 12)
                    .background(numberOfPlayers == count ? Color.blue : Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
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
            Text("Player Names & Colors")
              .font(.system(size: 18, weight: .semibold))
              .foregroundColor(.gray)

            ForEach(0..<min(numberOfPlayers, players.count), id: \.self) { index in
              playerNameAndColorRow(at: index)
            }
          }

          Button(action: {
            onPlayersChanged()
            gameHistory.clear()
            showMenu = false
          }) {
            Text("Reset Game")
              .font(.system(size: 18, weight: .bold))
              .foregroundColor(.white)
              .padding(.horizontal, 40)
              .padding(.vertical, 12)
              .background(Color.red.opacity(0.8))
              .cornerRadius(25)
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
  
  // Helper functions to break up complex expressions
  private func playerNameAndColorRow(at index: Int) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      TextField("Player \(index + 1)", text: $players[index].name)
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(presetColors, id: \.self) { color in
            colorCircle(for: color, at: index)
          }

          // Color Picker for custom colors
          customColorPicker(for: index)
        }
        .padding(10)
      }
    }
  }
  
  private func colorCircle(for color: CodableColor, at index: Int) -> some View {
    Circle()
      .fill(color.color)
      .frame(width: 30, height: 30)
      .overlay(
        Circle()
          .stroke(Color.white, lineWidth: players[index].color == color ? 3 : 0)
      )
      .onTapGesture {
        players[index].color = color
      }
  }
  
  private func customColorPicker(for index: Int) -> some View {
    let binding = Binding<Color>(
      get: { players[index].swiftUIColor },
      set: { players[index].color = CodableColor(color: $0) }
    )
    
    return ColorPicker("", selection: binding)
      .labelsHidden()
  }
}
