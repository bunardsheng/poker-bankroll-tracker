import Foundation

struct PokerSession: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let startTime: Date
    let endTime: Date
    let gameType: GameType
    let stakes: Stakes
    let location: String
    let buyIn: Double
    let cashOut: Double
    let notes: String?
    
    var profit: Double {
        cashOut - buyIn
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var hourlyRate: Double {
        let hours = duration / 3600
        return hours > 0 ? profit / hours : 0
    }
}

enum GameType: String, CaseIterable, Codable {
    case nlhe = "No Limit Hold'em"
    case plo = "Pot Limit Omaha"
    case mixed = "Mixed Games"
    case tournament = "Tournament"
    case sitAndGo = "Sit & Go"
    
    var shortName: String {
        switch self {
        case .nlhe: return "NLHE"
        case .plo: return "PLO"
        case .mixed: return "Mixed"
        case .tournament: return "Tournament"
        case .sitAndGo: return "SNG"
        }
    }
}

struct Stakes: Codable, Hashable {
    let smallBlind: Double
    let bigBlind: Double
    
    var description: String {
        if smallBlind < 1 && bigBlind < 1 {
            return "$\(String(format: "%.2f", smallBlind))/$\(String(format: "%.2f", bigBlind))"
        } else {
            return "$\(Int(smallBlind))/$\(Int(bigBlind))"
        }
    }
    
    static let common = [
        Stakes(smallBlind: 0.25, bigBlind: 0.50),
        Stakes(smallBlind: 0.50, bigBlind: 1.00),
        Stakes(smallBlind: 1.00, bigBlind: 2.00),
        Stakes(smallBlind: 2.00, bigBlind: 5.00),
        Stakes(smallBlind: 5.00, bigBlind: 10.00),
        Stakes(smallBlind: 10.00, bigBlind: 20.00),
        Stakes(smallBlind: 25.00, bigBlind: 50.00)
    ]
}