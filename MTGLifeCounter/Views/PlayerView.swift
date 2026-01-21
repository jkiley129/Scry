import SwiftUI

struct PlayerView: View {
  @Binding var player: Player

  @State private var recentChange: Int = 0
  @State private var changeTimer: Timer?

  private func recordChange(_ amount: Int) {
    // Invalidate existing timer
    changeTimer?.invalidate()

    // Apply immediate life change
    if amount < 0 {
      player.life = max(0, player.life + amount)
    } else {
      player.life += amount
    }

    // Update recent change with spring animation
    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
      recentChange += amount
    }

    // Restart timer to reset change indicator
    changeTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { _ in
      withAnimation(.easeOut(duration: 0.5)) {
        recentChange = 0
      }
    }
  }

  var body: some View {
    ZStack {
      player.color

      HStack(spacing: 0) {
        // Left half: Subtract Life
        Button(action: { recordChange(-1) }) {
          ZStack {
            Color.clear  // Ensures the button takes up the full frame

            // Icon
            Image(systemName: "minus.circle.fill")
              .font(.system(size: 60))
              .foregroundColor(.black.opacity(0.5))
              .padding(.trailing, 40)

            // Indicator Overlay (Only if negative change)
            if recentChange < 0 {
              Text("\(recentChange)")
                .font(.system(size: 50, weight: .heavy))
                .foregroundColor(.black)
                .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 1)
                .padding(.trailing, 40)  // Match icon padding
                .offset(y: -60)  // Position above icon
                .transition(.scale.combined(with: .opacity))
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .contentShape(Rectangle())
        }

        // Right half: Add Life
        Button(action: { recordChange(1) }) {
          ZStack {
            Color.clear

            // Icon
            Image(systemName: "plus.circle.fill")
              .font(.system(size: 60))
              .foregroundColor(.black.opacity(0.5))
              .padding(.leading, 40)

            // Indicator Overlay (Only if positive change)
            if recentChange > 0 {
              Text("+\(recentChange)")
                .font(.system(size: 50, weight: .heavy))
                .foregroundColor(.black)
                .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 1)
                .padding(.leading, 40)  // Match icon padding
                .offset(y: -60)  // Position above icon
                .transition(.scale.combined(with: .opacity))
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .contentShape(Rectangle())
        }
      }

      // Center Text Overlay
      Text("\(player.life)")
        .font(.system(size: 80, weight: .bold))
        .foregroundColor(.black)
        .allowsHitTesting(false)
    }
  }
}
