import Foundation

struct PokerSession: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let gameType: GameType
    let stakes: String
    let buyIn: Double
    let cashOut: Double
    let duration: TimeInterval
    let location: String?
    let notes: String?
    
    var profit: Double {
        cashOut - buyIn
    }
    
    var hourlyRate: Double {
        guard duration > 0 else { return 0 }
        return profit / (duration / 3600)
    }
}

enum GameType: String, CaseIterable, Codable {
    case nlhe = "No Limit Hold'em"
    case plo = "Pot Limit Omaha"
    case mixed = "Mixed Games"
    case tournament = "Tournament"
}