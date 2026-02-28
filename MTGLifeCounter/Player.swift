import SwiftUI

enum CounterType: String, CaseIterable, Identifiable, Hashable, Codable {
  case poison
  case energy
  case experience
  case tax

  var id: String { self.rawValue }
}

struct Player: Identifiable, Equatable, Codable {
  var id = UUID()
  var life: Int
  var name: String
  var color: CodableColor
  var commanderDamage: [UUID: Int] = [:]
  var counters: [CounterType: Int] = [:]
  
  // Helper for SwiftUI Color
  var swiftUIColor: Color {
    color.color
  }
}
// Wrapper to make Color Codable
struct CodableColor: Equatable, Codable, Hashable {
  var red: Double
  var green: Double
  var blue: Double
  var opacity: Double
  
  var color: Color {
    Color(red: red, green: green, blue: blue, opacity: opacity)
  }
  
  init(color: Color) {
    // Extract color components (default approximation)
    // Note: This is a simplified version. For production, you might want UIColor conversion
    let uiColor = UIColor(color)
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
    
    self.red = Double(r)
    self.green = Double(g)
    self.blue = Double(b)
    self.opacity = Double(a)
  }
  
  // Hashable conformance
  func hash(into hasher: inout Hasher) {
    hasher.combine(red)
    hasher.combine(green)
    hasher.combine(blue)
    hasher.combine(opacity)
  }
  
  static var red: CodableColor { CodableColor(color: .red) }
  static var blue: CodableColor { CodableColor(color: .blue) }
  static var green: CodableColor { CodableColor(color: .green) }
  static var orange: CodableColor { CodableColor(color: .orange) }
  static var purple: CodableColor { CodableColor(color: .purple) }
  static var pink: CodableColor { CodableColor(color: .pink) }
  static var yellow: CodableColor { CodableColor(color: .yellow) }
  static var gray: CodableColor { CodableColor(color: .gray) }
  static var black: CodableColor { CodableColor(color: .black) }
  static var white: CodableColor { CodableColor(color: .white) }
}

