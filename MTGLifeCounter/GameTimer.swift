import Foundation
import Combine

class GameTimer: ObservableObject {
  @Published var elapsedTime: TimeInterval = 0
  @Published var isRunning: Bool = false
  
  private var startTime: Date?
  private var pausedTime: TimeInterval = 0
  private var timer: Timer?
  
  var formattedTime: String {
    let hours = Int(elapsedTime) / 3600
    let minutes = (Int(elapsedTime) % 3600) / 60
    let seconds = Int(elapsedTime) % 60
    
    if hours > 0 {
      return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else {
      return String(format: "%d:%02d", minutes, seconds)
    }
  }
  
  func start() {
    guard !isRunning else { return }
    isRunning = true
    startTime = Date()
    
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      guard let self = self, let start = self.startTime else { return }
      self.elapsedTime = self.pausedTime + Date().timeIntervalSince(start)
    }
  }
  
  func pause() {
    guard isRunning else { return }
    isRunning = false
    
    if let start = startTime {
      pausedTime += Date().timeIntervalSince(start)
    }
    
    timer?.invalidate()
    timer = nil
    startTime = nil
  }
  
  func reset() {
    isRunning = false
    elapsedTime = 0
    pausedTime = 0
    startTime = nil
    timer?.invalidate()
    timer = nil
  }
  
  func resume(from savedTime: Date) {
    let elapsed = Date().timeIntervalSince(savedTime)
    pausedTime = elapsed
    elapsedTime = elapsed
    start()
  }
  
  deinit {
    timer?.invalidate()
  }
}
