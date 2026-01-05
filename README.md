# Scry - MTG Life Counter

A sleek iOS life counter app for Magic: The Gathering with support for 2-4 players.

## Features

- **2-4 Player Support**: Track life totals for multiplayer games
- **Commander Mode**: Toggle between standard (20 life) and Commander (40 life) formats
- **Customizable Player Colors**: Choose from preset colors or use a custom color picker
- **Dynamic Layout**:
  - 2 players: Split-screen vertical layout
  - 4 players: Quadrant layout with rotated views for easy viewing from any seat
- **Game Over Detection**: Automatic detection when a player's life reaches zero with "GGs" screen
- **Mystical Splash Screen**: Animated intro with MTG-themed mana orbs and particle effects
- **Hexagonal Menu Button**: Clean, centered menu access during gameplay
- **Portrait Lock**: Optimized for portrait orientation

## Tech Stack

- SwiftUI
- iOS 16+
- Portrait-only interface
- Custom shapes (Hexagon)
- Particle animations

## Getting Started

1. Open `MTGLifeCounter.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (Cmd+R)

## Project Structure

- `ScryApp.swift` - App entry point with splash screen logic
- `Views/`
  - `ContentView.swift` - Main game view with layout logic
  - `PlayerView.swift` - Individual player life counter with +/- buttons
  - `SettingsMenuView.swift` - Configuration menu for players, colors, and game mode
  - `SplashScreenView.swift` - Animated splash screen with MTG theming
  - `HexagonShape.swift` - Custom hexagonal shape for menu button
- `Player.swift` - Player data model

## Usage

### Starting a Game
- App automatically starts with 2 players at 20 life
- Tap the hexagonal "Menu" button to adjust settings

### Adjusting Settings
- **Number of Players**: Toggle between 2 or 4 players
- **Game Mode**: Enable Commander mode for 40 starting life
- **Player Colors**: Customize each player's background color for easy identification

### During Gameplay
- Tap **+** or **-** buttons to modify life totals
- Layout automatically adjusts based on player count
- Game ends automatically when any player reaches 0 life

### Restarting
- When game ends, tap "Restart Game" to start fresh with current settings
