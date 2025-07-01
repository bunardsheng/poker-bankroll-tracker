# 🎯 Poker Bankroll Tracker

A sleek, AI-powered iOS app for tracking poker sessions. Features a dark command center aesthetic with neon glow effects, making you feel like a sharp, analytical poker pro with a real-time edge.

## ✨ Features

### 🎨 Aesthetic Dashboard
- **Dark Command Center Aesthetic**: Sleek, covert design that makes you feel like a sharp, analytical poker pro
- **Neon Glow Effects**: Teal and electric purple accents with subtle pulse animations
- **Mono-spaced Fonts**: Clean, technical typography for that professional edge
- **Pulse Animations**: Bankroll and AI elements glow with subtle breathing effects

### 💰 Bankroll Management
- **Real-time Bankroll Display**: Large, prominent bankroll with neon glow effects
- **Monthly Change Tracking**: Shows profit/loss with colored indicators (`Up $2,300 this month`)
- **Smart Calculations**: Automatic profit/loss tracking with hourly rate analysis

### 🧠 AI-Powered Insights ("Your Edge")
- **Smart Analytics**: AI-generated insights about your poker performance
- **Rotating Cards**: Horizontally swipeable insight panels with flat translucent backgrounds
- **Actionable Recommendations**: Get specific advice to improve your game
- **AI Pulse Indicators**: Brain icon with animated pulse effects

### 📊 Session Tracking
- **Compact Session Rows**: Clean format: `[🟢 +$240] 2/5 NLHE - Bellagio`
- **Detailed Information**: `3h 25m · June 28 · 7:00PM` format
- **Colored Borders**: Win/loss indicators with neon teal and red accents
- **Tap Animations**: Smooth scale and opacity effects on interaction

### 📈 Performance Analytics
- **Trend Analysis**: Recent performance with visual up/down indicators
- **Streak Tracking**: Current winning/losing streaks with flame icons
- **Game Type Analysis**: Best performing poker variants
- **Visual Charts**: Clean, modern performance cards with theme colors

## App Structure

### Models
- `PokerSession` - Core session data model
- `PlayerStats` - Performance statistics tracking
- `AIInsight` - AI-generated insights and recommendations
- `PreSessionPrompt` - Preparation prompts and tips

### Views
- `DashboardView` - Main overview with stats and quick actions
- `SessionLogView` - Swipe-based session entry interface
- `PreSessionPrepView` - Preparation prompts and checklist
- `AnalyticsView` - Charts and detailed performance analysis
- `SessionListView` - Searchable list of all sessions
- `SettingsView` - App preferences and data management

### Services
- `SessionManager` - Session data persistence and management
- `AIInsightsService` - Performance analysis and insight generation

## 🚀 Getting Started

1. Clone this repository
2. Open `pokertracker.xcodeproj` in Xcode
3. Build and run on iOS Simulator or device
4. Start logging your poker sessions!

## 🎮 Usage

1. **Log Sessions**: Tap the + button to add new poker sessions
2. **View Analytics**: Browse AI insights and performance trends
3. **Track Progress**: Monitor your bankroll growth over time
4. **Get Insights**: Receive AI-powered recommendations to improve your game

## Key Features Explained

### Swipe-Based Session Logging
The session logging interface uses a card-based, swipe-driven UI that guides users through:
1. Game type selection
2. Stakes and table configuration
3. Buy-in amount and session timer
4. Location and cash-out details
5. Session notes

### AI Insights Engine
The app analyzes your session data to provide insights on:
- **Performance trends** - Identifies winning/losing streaks
- **Bankroll management** - Warns about proper bankroll ratios
- **Session length analysis** - Identifies optimal session durations
- **Time-based patterns** - Weekend vs weekday performance
- **Variance tracking** - Helps understand result swings

### Pre-Session Preparation
Before each session, the app can guide you through:
- Mental state check-in
- Bankroll verification
- Strategy focus areas
- Session goal setting
- Recent performance review

## 🛠 Tech Stack

- **Framework**: SwiftUI
- **Platform**: iOS 18.2+
- **Language**: Swift 5
- **Architecture**: MVVM
- **Data Persistence**: UserDefaults with Codable models
- **Design System**: Custom Cluely theme with neon accents

## 🎯 Design Philosophy

This app embodies the aesthetic of a professional poker player's command center:
- **Analytical**: Clean, data-driven interface
- **Covert**: Dark theme with subtle glow effects
- **Professional**: Mono-spaced fonts and precise layouts
- **Intelligent**: AI-powered insights with modern animations

## 🎨 Theme Colors

- **Neon Teal**: `Color(red: 0.0, green: 0.8, blue: 0.8)`
- **Electric Purple**: `Color(red: 0.5, green: 0.2, blue: 1.0)`
- **Dark Background**: `Color(red: 0.08, green: 0.08, blue: 0.12)`

## 📋 Requirements

- Xcode 15.0+
- iOS 18.2+
- Swift 5.0+

## Data Storage

- Local storage using UserDefaults for session persistence
- No external dependencies or cloud services required
- Export/import functionality for data portability

## 📱 Screenshots

*Coming soon - build and run to see the design in action!*

## 🤝 Contributing

Feel free to submit issues, feature requests, or pull requests to improve the app!

## 📄 License

MIT License - feel free to use this project as inspiration for your own poker tracking apps.

---

*Built with ❤️ for the poker community*
