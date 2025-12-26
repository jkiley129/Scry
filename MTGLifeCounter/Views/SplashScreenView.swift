import SwiftUI

struct SplashScreenView: View {
  @State private var isAnimating = false
  @State private var particles: [Particle] = []

  var body: some View {
    ZStack {
      // Dark mystical background with gradient
      LinearGradient(
        gradient: Gradient(colors: [
          Color(red: 0.05, green: 0.05, blue: 0.15),
          Color(red: 0.1, green: 0.05, blue: 0.2),
          Color(red: 0.05, green: 0.1, blue: 0.25),
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      // Magical particles/stars background
      ForEach(particles) { particle in
        Circle()
          .fill(particle.color.opacity(particle.opacity))
          .frame(width: particle.size, height: particle.size)
          .position(particle.position)
          .blur(radius: 1)
      }

      VStack(spacing: 20) {
        // Main title with mystical styling
        ZStack {
          // Outer glow layers
          Text("SCRY")
            .font(.system(size: 80, weight: .black, design: .serif))
            .foregroundStyle(
              LinearGradient(
                colors: [
                  Color(red: 0.4, green: 0.6, blue: 1.0),
                  Color(red: 0.6, green: 0.4, blue: 0.9),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .shadow(color: Color.blue.opacity(0.8), radius: 20, x: 0, y: 0)
            .shadow(color: Color.purple.opacity(0.6), radius: 30, x: 0, y: 0)
            .scaleEffect(isAnimating ? 1.0 : 0.5)
            .opacity(isAnimating ? 1.0 : 0.0)
        }

        // Subtitle with MTG flavor
        Text("Magic Life Counter")
          .font(.system(size: 16, weight: .medium, design: .serif))
          .foregroundColor(Color(red: 0.7, green: 0.8, blue: 1.0))
          .tracking(3)
          .opacity(isAnimating ? 0.8 : 0.0)
          .offset(y: isAnimating ? 0 : 20)

        // Decorative mana-like orbs
        HStack(spacing: 15) {
          ForEach(0..<5, id: \.self) { index in
            Circle()
              .fill(
                LinearGradient(
                  colors: [manaColor(for: index), manaColor(for: index).opacity(0.3)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .frame(width: 12, height: 12)
              .shadow(color: manaColor(for: index).opacity(0.8), radius: 8, x: 0, y: 0)
              .scaleEffect(isAnimating ? 1.0 : 0.0)
              .animation(
                .spring(response: 0.6, dampingFraction: 0.6)
                  .delay(Double(index) * 0.1 + 0.3),
                value: isAnimating
              )
          }
        }
        .padding(.top, 10)
        .opacity(isAnimating ? 1.0 : 0.0)
      }
    }
    .onAppear {
      // Generate random particles
      particles = (0..<50).map { _ in
        Particle(
          position: CGPoint(
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
          ),
          size: CGFloat.random(in: 1...3),
          color: Bool.random() ? .blue : .purple,
          opacity: Double.random(in: 0.2...0.6)
        )
      }

      // Start animations
      withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
        isAnimating = true
      }

      // Animate particles
      animateParticles()
    }
  }

  private func manaColor(for index: Int) -> Color {
    let colors: [Color] = [
      Color(red: 0.9, green: 0.9, blue: 0.7),  // White mana
      Color(red: 0.4, green: 0.6, blue: 1.0),  // Blue mana
      Color(red: 0.3, green: 0.3, blue: 0.4),  // Black mana
      Color(red: 1.0, green: 0.3, blue: 0.3),  // Red mana
      Color(red: 0.4, green: 0.8, blue: 0.4),  // Green mana
    ]
    return colors[index % colors.count]
  }

  private func animateParticles() {
    Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
      for i in 0..<particles.count {
        particles[i].position.y -= CGFloat.random(in: 0.2...0.8)
        particles[i].opacity = Double.random(in: 0.2...0.6)

        // Reset particles that go off screen
        if particles[i].position.y < 0 {
          particles[i].position.y = UIScreen.main.bounds.height
          particles[i].position.x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
        }
      }
    }
  }
}

struct Particle: Identifiable {
  let id = UUID()
  var position: CGPoint
  var size: CGFloat
  var color: Color
  var opacity: Double
}
