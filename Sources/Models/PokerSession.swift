import Foundation

enum GameType: String, CaseIterable, Codable {
    case nlhe = "No Limit Hold'em"
    case plo = "Pot Limit Omaha"
    case plo5 = "5-Card PLO"
    case stud = "7-Card Stud"
    case razz = "Razz"
    case tournament = "Tournament"
    case sitAndGo = "Sit & Go"
    case other = "Other"
    
    var displayName: String {
        return self.rawValue
    }
    
    var emoji: String {
        switch self {
        case .nlhe: return "♠️"
        case .plo: return "♦️"
        case .plo5: return "♥️"
        case .stud: return "♣️"
        case .razz: return "🃏"
        case .tournament: return "🏆"
        case .sitAndGo: return "🎯"
        case .other: return "🎲"
        }
    }
}

enum SessionState: String, Codable {
    case setup
    case inProgress
    case completed
    case cancelled
}

struct StakesLevel: Codable, Hashable {
    let smallBlind: Double
    let bigBlind: Double
    let ante: Double?
    
    var displayString: String {
        if let ante = ante, ante > 0 {
            return "$\(Int(smallBlind))/$\(Int(bigBlind)) ($\(Int(ante)) ante)"
        } else {
            return "$\(Int(smallBlind))/$\(Int(bigBlind))"
        }
    }
    
    static let commonStakes: [StakesLevel] = [
        StakesLevel(smallBlind: 1, bigBlind: 2, ante: nil),
        StakesLevel(smallBlind: 1, bigBlind: 3, ante: nil),
        StakesLevel(smallBlind: 2, bigBlind: 5, ante: nil),
        StakesLevel(smallBlind: 5, bigBlind: 10, ante: nil),
        StakesLevel(smallBlind: 10, bigBlind: 20, ante: nil),
        StakesLevel(smallBlind: 25, bigBlind: 50, ante: nil),
        StakesLevel(smallBlind: 50, bigBlind: 100, ante: nil),
        StakesLevel(smallBlind: 100, bigBlind: 200, ante: nil),
        StakesLevel(smallBlind: 200, bigBlind: 400, ante: nil),
        StakesLevel(smallBlind: 500, bigBlind: 1000, ante: nil)
    ]
}

struct PokerSession: Identifiable, Codable {
    let id = UUID()
    var gameType: GameType
    var stakes: StakesLevel?
    var location: String
    var buyIn: Double
    var cashOut: Double?
    var startTime: Date
    var endTime: Date?
    var notes: String
    var state: SessionState
    
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    var profit: Double? {
        guard let cashOut = cashOut else { return nil }
        return cashOut - buyIn
    }
    
    var isInProgress: Bool {
        return state == .inProgress
    }
    
    var formattedDuration: String {
        guard let duration = duration else {
            let currentDuration = Date().timeIntervalSince(startTime)
            return formatTimeInterval(currentDuration)
        }
        return formatTimeInterval(duration)
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    init(gameType: GameType, location: String = "", buyIn: Double = 0) {
        self.gameType = gameType
        self.location = location
        self.buyIn = buyIn
        self.startTime = Date()
        self.notes = ""
        self.state = .setup
    }
}

extension PokerSession {
    static let sampleSession = PokerSession(
        gameType: .nlhe,
        location: "Aria Casino",
        buyIn: 500
    )
}