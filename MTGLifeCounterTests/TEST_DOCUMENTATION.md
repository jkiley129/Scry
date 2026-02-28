# MTG Life Counter - Test Suite Documentation

## Overview

This test suite provides comprehensive coverage of the MTG Life Counter app, ensuring reliability, correctness, and performance across all features.

## Test Files

### 1. DataModelTests.swift
**Purpose**: Core data model validation using Swift Testing framework

**Test Suites**:
- **Player Model Tests** (18 tests)
  - Initialization and property validation
  - Life total tracking
  - Commander damage tracking (single and multiple opponents)
  - Counter management (poison, energy, experience, tax)
  - Player equality and uniqueness
  
- **Game History Tests** (8 tests)
  - Entry creation and ordering
  - Clear functionality
  - Timestamp validation
  - Multi-player tracking

- **Counter Type Tests** (4 tests)
  - Enum case validation
  - Raw values and IDs
  - Hashability

- **History Entry Tests** (3 tests)
  - Property validation
  - Equality testing

- **Game Logic Tests** (11 tests)
  - Win condition validation
  - Life total boundaries
  - Poison counter mechanics
  - Commander damage rules
  - Multiple win conditions

- **Multi-Player Game Tests** (6 tests)
  - 2, 4, and 6 player setups
  - Unique ID validation
  - Independent player states

**Total Tests**: 50

### 2. HexagonShapeTests.swift
**Purpose**: Validate the custom hexagon shape used for UI buttons

**Test Cases** (7 tests):
- Path creation and validity
- Closed path verification
- Size adaptation
- Centering within rects
- Edge cases (non-square rects, zero dimensions)

### 3. GameScenarioTests.swift
**Purpose**: Integration tests for realistic game scenarios

**Test Suites**:
- **Standard Game Scenarios** (3 tests)
  - 1v1 complete games
  - Poison counter wins
  - Commander damage lethal scenarios

- **Commander Game Scenarios** (2 tests)
  - 4-player setup
  - Multiple damage sources

- **Complex Counter Scenarios** (4 tests)
  - Energy accumulation
  - Experience progression
  - Tax counter tracking
  - Multiple simultaneous counters

- **Edge Case Scenarios** (6 tests)
  - Life oscillation
  - Near-death recovery
  - Exact lethal damage
  - Overkill damage
  - Multiple win conditions

- **History Tracking Scenarios** (2 tests)
  - Full game progression
  - Chronological ordering

- **Game Reset Scenarios** (2 tests)
  - State clearing
  - Mode switching

- **Six Player Game Scenarios** (2 tests)
  - 6-player pod setup
  - Commander damage with 5 opponents

**Total Tests**: 21

### 4. EdgeCaseTests.swift
**Purpose**: Boundary condition and edge case validation

**Test Suites**:
- **Life Total Edge Cases** (6 tests)
  - Very high/low values
  - Integer bounds
  - Zero life handling
  - Precise increments

- **Commander Damage Edge Cases** (6 tests)
  - Zero values
  - Exact thresholds
  - Over-lethal damage
  - Multiple commanders

- **Counter Edge Cases** (6 tests)
  - Lethal thresholds
  - Removal operations
  - Very high values
  - All counter types at max

- **Game History Edge Cases** (8 tests)
  - Empty history
  - Single entries
  - Very long history (1000+ entries)
  - Empty and long messages
  - Multiple clears

- **Player Color Edge Cases** (3 tests)
  - Standard colors
  - Custom colors
  - Shared colors

- **UUID Edge Cases** (2 tests)
  - Uniqueness at scale (1000 players)
  - History entry uniqueness

- **State Consistency Tests** (2 tests)
  - Multi-operation consistency
  - History/player sync

- **Counter Type Enumeration Tests** (2 tests)
  - Iteration
  - Ordering

**Total Tests**: 35

### 5. PerformanceTests.swift
**Purpose**: Stress testing and performance validation

**Test Suites**:
- **Player Creation Performance** (4 tests)
  - Creating 10,000 players
  - Rapid life modifications
  - Many commander damage sources
  - Rapid counter changes

- **Game History Performance** (3 tests)
  - Adding 10,000 entries
  - Clearing large history
  - Repeated add/clear cycles

- **Complex Game State Performance** (2 tests)
  - Full 6-player game with complete state
  - 100-turn game simulation

- **Data Structure Performance** (2 tests)
  - Dictionary lookups
  - Counter type switching

- **Memory Efficiency Tests** (3 tests)
  - Value type semantics
  - Independent copies

- **Rapid State Change Tests** (2 tests)
  - 1000 game restarts
  - Alternating operations

- **Concurrent-like Operations** (2 tests)
  - Sequential modifications
  - Interleaved history

- **Realistic Game Simulation** (1 test)
  - Complete 30-turn 4-player game

**Total Tests**: 19

## Test Coverage Summary

### Total Test Count: **132 Tests**

### Coverage by Feature:
- **Player Model**: 35+ tests
- **Game History**: 18+ tests
- **Commander Damage**: 15+ tests
- **Counters**: 20+ tests
- **Game Logic**: 25+ tests
- **Performance**: 19+ tests
- **UI Components**: 7+ tests

### Coverage by Type:
- **Unit Tests**: ~80 tests
- **Integration Tests**: ~25 tests
- **Performance Tests**: ~19 tests
- **Edge Case Tests**: ~35 tests

## Running the Tests

### Using Xcode
1. Open the project in Xcode
2. Press `Cmd + U` to run all tests
3. Or use `Cmd + 6` to open the Test Navigator and run specific test suites

### Using Command Line
```bash
xcodebuild test -scheme MTGLifeCounter -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Running Specific Test Suites
In Xcode Test Navigator:
- Click the diamond next to a test suite to run all tests in that suite
- Click individual test diamonds to run single tests
- Use the filter at the bottom to search for specific tests

## Test Philosophy

### Modern Swift Testing Framework
All tests use the new Swift Testing framework with:
- `@Test` attributes for clear test identification
- `@Suite` for logical grouping
- `#expect` for clear assertions
- `#require` for optional unwrapping

### Test Coverage Goals
- **Correctness**: Verify all game rules (MTG life totals, poison, commander damage)
- **Robustness**: Handle edge cases and boundary conditions
- **Performance**: Ensure app remains responsive with complex game states
- **Integration**: Validate realistic game scenarios
- **Regression Prevention**: Catch bugs before they reach production

## Key Test Scenarios Covered

### MTG Game Rules
✅ Standard game: 20 starting life
✅ Commander game: 40 starting life
✅ Poison counters: lethal at 10
✅ Commander damage: lethal at 21 from single source
✅ Life can go negative
✅ Commander damage tracked per opponent

### Data Integrity
✅ Player IDs are unique
✅ History entries maintain chronological order
✅ Counters are independent
✅ Value type semantics for Player struct
✅ State consistency across operations

### Scale and Performance
✅ Handles 10,000+ players
✅ Manages 10,000+ history entries
✅ Supports rapid state changes
✅ Efficient dictionary operations
✅ Memory-efficient value types

### User Experience
✅ Game reset clears all state
✅ History tracks all actions
✅ Multi-player support (2-6 players)
✅ Mode switching (Standard ↔ Commander)

## Continuous Improvement

### Adding New Tests
When adding new features:
1. Write tests first (TDD approach)
2. Cover happy path and edge cases
3. Add integration tests for user scenarios
4. Document the test purpose

### Test Maintenance
- Review tests when updating game rules
- Add tests for bug fixes to prevent regression
- Keep test names descriptive
- Group related tests in suites

## Known Test Gaps (Future Enhancements)

### UI Testing (Not Covered)
- View rendering
- Button interactions
- Navigation flows
- Animations

### User Defaults/Persistence
- Saving game state
- Loading previous games
- Settings persistence

### Recommendations for Additional Tests
1. Add UI tests using XCUITest for critical user flows
2. Add persistence layer tests when storage is implemented
3. Consider snapshot tests for visual regression
4. Add accessibility tests

## Conclusion

This test suite provides robust coverage of the MTG Life Counter's core functionality. With 132 tests covering models, game logic, edge cases, and performance, the app is well-protected against regressions and ready for production use.

The use of Swift Testing framework ensures tests are maintainable, readable, and fast. All critical MTG game rules are validated, and the app can handle extreme scenarios gracefully.
