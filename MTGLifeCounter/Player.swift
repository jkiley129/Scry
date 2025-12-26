import SwiftUI

struct Player: Identifiable, Equatable {
  let id = UUID()
  var life: Int
  var color: Color
}
