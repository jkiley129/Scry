import Foundation

// Represents an action that can be undone
enum GameAction: Equatable {
  case lifeChange(playerId: UUID, previousLife: Int, newLife: Int)
  case counterChange(playerId: UUID, counterType: CounterType, previousValue: Int?, newValue: Int?)
  case commanderDamageChange(playerId: UUID, opponentId: UUID, previousDamage: Int?, newDamage: Int?)
  
  var playerId: UUID {
    switch self {
    case .lifeChange(let id, _, _),
         .counterChange(let id, _, _, _),
         .commanderDamageChange(let id, _, _, _):
      return id
    }
  }
  
  var description: String {
    switch self {
    case .lifeChange(_, let prev, let new):
      let change = new - prev
      return "Life \(change > 0 ? "+" : "")\(change)"
    case .counterChange(_, let type, _, _):
      return "\(type.rawValue.capitalized) counter change"
    case .commanderDamageChange:
      return "Commander damage change"
    }
  }
}

// Stack to manage undo/redo
class ActionStack: ObservableObject {
  @Published var undoStack: [GameAction] = []
  @Published var redoStack: [GameAction] = []
  
  var canUndo: Bool {
    !undoStack.isEmpty
  }
  
  var canRedo: Bool {
    !redoStack.isEmpty
  }
  
  func addAction(_ action: GameAction) {
    undoStack.append(action)
    redoStack.removeAll() // Clear redo stack when new action is performed
  }
  
  func undo() -> GameAction? {
    guard let action = undoStack.popLast() else { return nil }
    redoStack.append(action)
    return action
  }
  
  func redo() -> GameAction? {
    guard let action = redoStack.popLast() else { return nil }
    undoStack.append(action)
    return action
  }
  
  func clear() {
    undoStack.removeAll()
    redoStack.removeAll()
  }
}
