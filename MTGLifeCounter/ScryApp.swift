import SwiftUI

@main
struct ScryApp: App {
  @StateObject private var gameHistory = GameHistory()
  @State private var showingSplashScreen = true

  var body: some Scene {
    WindowGroup {
      ZStack {
        ContentView()
          .environmentObject(gameHistory)

        if showingSplashScreen {
          SplashScreenView()
            .transition(.opacity)
            .zIndex(1)
            .onAppear {
              // Hide splash screen after 2.5 seconds
              DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.8)) {
                  showingSplashScreen = false
                }
              }
            }
        }
      }
    }
  }
}
