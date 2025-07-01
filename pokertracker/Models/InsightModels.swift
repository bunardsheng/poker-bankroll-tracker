import Foundation

struct Insight: Identifiable, Codable {
    let id = UUID()
    let type: InsightType
    let priority: InsightPriority
    let title: String
    let message: String
    let actionableRecommendation: String
    let confidence: Double
    let relevantData: [String: Double]
    let createdAt: Date
    
    init(type: InsightType, priority: InsightPriority, title: String, message: String, actionableRecommendation: String, confidence: Double, relevantData: [String: Double] = [:]) {
        self.type = type
        self.priority = priority
        self.title = title
        self.message = message
        self.actionableRecommendation = actionableRecommendation
        self.confidence = confidence
        self.relevantData = relevantData
        self.createdAt = Date()
    }
}

enum InsightType: String, CaseIterable, Codable {
    case timeBasedPerformance = "time_performance"
    case streakAnalysis = "streak_analysis"
    case bankrollManagement = "bankroll_management"
    case varianceAnalysis = "variance_analysis"
    case sessionOptimization = "session_optimization"
    case gameSelection = "game_selection"
    case tiltDetection = "tilt_detection"
}

enum InsightPriority: String, CaseIterable, Codable {
    case critical = "critical"
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var color: String {
        switch self {
        case .critical: return "red"
        case .high: return "orange"
        case .medium: return "yellow"
        case .low: return "green"
        }
    }
}

struct PerformanceMetrics: Codable {
    let totalSessions: Int
    let totalProfit: Double
    let winRate: Double
    let averageHourlyRate: Double
    let bestStreak: Int
    let worstStreak: Int
    let currentStreak: Int
    let standardDeviation: Double
    let bigBlindsPer100: Double?
    
    init(sessions: [PokerSession]) {
        self.totalSessions = sessions.count
        self.totalProfit = sessions.reduce(0) { $0 + $1.profit }
        self.winRate = sessions.isEmpty ? 0 : Double(sessions.filter { $0.profit > 0 }.count) / Double(sessions.count)
        self.averageHourlyRate = sessions.isEmpty ? 0 : sessions.reduce(0) { $0 + $1.hourlyRate } / Double(sessions.count)
        
        let streaks = PerformanceMetrics.calculateStreaks(sessions: sessions)
        self.bestStreak = streaks.best
        self.worstStreak = streaks.worst
        self.currentStreak = streaks.current
        
        self.standardDeviation = PerformanceMetrics.calculateStandardDeviation(sessions: sessions)
        self.bigBlindsPer100 = PerformanceMetrics.calculateBBPer100(sessions: sessions)
    }
    
    private static func calculateStreaks(sessions: [PokerSession]) -> (best: Int, worst: Int, current: Int) {
        guard !sessions.isEmpty else { return (0, 0, 0) }
        
        let sortedSessions = sessions.sorted { $0.date < $1.date }
        var currentWinStreak = 0
        var currentLossStreak = 0
        var bestWinStreak = 0
        var worstLossStreak = 0
        var finalStreak = 0
        
        for session in sortedSessions {
            if session.profit > 0 {
                currentWinStreak += 1
                currentLossStreak = 0
                bestWinStreak = max(bestWinStreak, currentWinStreak)
                finalStreak = currentWinStreak
            } else {
                currentLossStreak += 1
                currentWinStreak = 0
                worstLossStreak = max(worstLossStreak, currentLossStreak)
                finalStreak = -currentLossStreak
            }
        }
        
        return (bestWinStreak, worstLossStreak, finalStreak)
    }
    
    private static func calculateStandardDeviation(sessions: [PokerSession]) -> Double {
        guard sessions.count > 1 else { return 0 }
        
        let profits = sessions.map { $0.profit }
        let mean = profits.reduce(0, +) / Double(profits.count)
        let squaredDifferences = profits.map { pow($0 - mean, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(profits.count - 1)
        
        return sqrt(variance)
    }
    
    private static func calculateBBPer100(sessions: [PokerSession]) -> Double? {
        let cashGameSessions = sessions.filter { $0.gameType != .tournament }
        guard !cashGameSessions.isEmpty else { return nil }
        
        return cashGameSessions.reduce(0) { $0 + $1.hourlyRate } / Double(cashGameSessions.count)
    }
}