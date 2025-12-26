import SwiftUI

struct PlayerView: View {
  @Binding var player: Player
  var rotation: Double = 0

  var body: some View {
    ZStack {
      player.color
      HStack(spacing: 40) {
        Button(action: { player.life = max(0, player.life - 1) }) {
          Image(systemName: "minus.circle.fill")
            .font(.system(size: 60))
            .foregroundColor(.black.opacity(0.5))  // Slightly softer than plain red on varied backgrounds
        }
        Text("\(player.life)")
          .font(.system(size: 80, weight: .bold))
          .foregroundColor(.black)
          .fixedSize()
          .frame(minWidth: 100)
        Button(action: { player.life += 1 }) {
          Image(systemName: "plus.circle.fill")
            .font(.system(size: 60))
            .foregroundColor(.black.opacity(0.5))  // Slightly softer than plain green
        }
      }
      .rotationEffect(.degrees(rotation))
    }
  }
}
