import Foundation
import Combine

class AIInsightsService: ObservableObject {
    @Published var insights: [Insight] = []
    @Published var isGeneratingInsights = false
    
    private let minimumSessionsForInsights = 5
    
    func generateInsights(from sessions: [PokerSession]) async {
        await MainActor.run {
            isGeneratingInsights = true
        }
        
        guard sessions.count >= minimumSessionsForInsights else {
            await MainActor.run {
                insights = [createInsufficientDataInsight()]
                isGeneratingInsights = false
            }
            return
        }
        
        let metrics = PerformanceMetrics(sessions: sessions)
        var generatedInsights: [Insight] = []
        
        generatedInsights.append(contentsOf: await analyzeTimeBasedPerformance(sessions: sessions, metrics: metrics))
        generatedInsights.append(contentsOf: await analyzeStreakPatterns(sessions: sessions, metrics: metrics))
        generatedInsights.append(contentsOf: await analyzeBankrollManagement(sessions: sessions, metrics: metrics))
        generatedInsights.append(contentsOf: await analyzeVariance(sessions: sessions, metrics: metrics))
        generatedInsights.append(contentsOf: await analyzeSessionOptimization(sessions: sessions, metrics: metrics))
        
        generatedInsights.sort { $0.priority.rawValue < $1.priority.rawValue }
        
        await MainActor.run {
            insights = Array(generatedInsights.prefix(8))
            isGeneratingInsights = false
        }
    }
    
    private func createInsufficientDataInsight() -> Insight {
        Insight(
            type: .sessionOptimization,
            priority: .medium,
            title: "More Data Needed",
            message: "Play at least \(minimumSessionsForInsights) sessions to unlock AI insights.",
            actionableRecommendation: "Log your next poker sessions to start receiving personalized analytics and recommendations.",
            confidence: 1.0
        )
    }
}

extension AIInsightsService {
    private func analyzeTimeBasedPerformance(sessions: [PokerSession], metrics: PerformanceMetrics) async -> [Insight] {
        var insights: [Insight] = []
        
        let recentSessions = Array(sessions.sorted { $0.date > $1.date }.prefix(10))
        let recentPerformance = recentSessions.reduce(0) { $0 + $1.profit }
        let recentWinRate = Double(recentSessions.filter { $0.profit > 0 }.count) / Double(recentSessions.count)
        
        if recentWinRate < 0.3 && recentSessions.count >= 5 {
            insights.append(Insight(
                type: .timeBasedPerformance,
                priority: .high,
                title: "Recent Downswing Detected",
                message: "Your win rate in the last \(recentSessions.count) sessions is \(String(format: "%.0f", recentWinRate * 100))%, significantly below your overall \(String(format: "%.0f", metrics.winRate * 100))%.",
                actionableRecommendation: "Consider taking a break to review your game, study recent hands, or drop down in stakes temporarily.",
                confidence: 0.85,
                relevantData: ["recent_winrate": recentWinRate, "overall_winrate": metrics.winRate]
            ))
        }
        
        let hourlyData = analyzeHourlyPerformance(sessions: sessions)
        if let bestHour = hourlyData.max(by: { $0.value < $1.value }) {
            insights.append(Insight(
                type: .timeBasedPerformance,
                priority: .medium,
                title: "Peak Performance Time",
                message: "You perform best around \(bestHour.key):00 with an average profit of $\(String(format: "%.0f", bestHour.value)).",
                actionableRecommendation: "Schedule more sessions during your peak hours (\(bestHour.key):00-\(bestHour.key + 2):00) to maximize profits.",
                confidence: 0.75,
                relevantData: ["best_hour": Double(bestHour.key), "best_hour_profit": bestHour.value]
            ))
        }
        
        return insights
    }
    
    private func analyzeStreakPatterns(sessions: [PokerSession], metrics: PerformanceMetrics) async -> [Insight] {
        var insights: [Insight] = []
        
        if metrics.currentStreak <= -3 {
            insights.append(Insight(
                type: .streakAnalysis,
                priority: .critical,
                title: "Extended Losing Streak",
                message: "You're currently on a \(abs(metrics.currentStreak))-session losing streak. Your worst streak was \(metrics.worstStreak) sessions.",
                actionableRecommendation: "Consider taking a break, reviewing your recent play, or dropping down in stakes until the streak breaks.",
                confidence: 0.95,
                relevantData: ["current_streak": Double(metrics.currentStreak), "worst_streak": Double(metrics.worstStreak)]
            ))
        } else if metrics.currentStreak >= 5 {
            insights.append(Insight(
                type: .streakAnalysis,
                priority: .low,
                title: "Hot Streak Active",
                message: "You're on a \(metrics.currentStreak)-session winning streak! Your best streak was \(metrics.bestStreak) sessions.",
                actionableRecommendation: "Stay focused and maintain your current approach. Consider moving up in stakes if your bankroll allows.",
                confidence: 0.80,
                relevantData: ["current_streak": Double(metrics.currentStreak), "best_streak": Double(metrics.bestStreak)]
            ))
        }
        
        return insights
    }
    
    private func analyzeBankrollManagement(sessions: [PokerSession], metrics: PerformanceMetrics) async -> [Insight] {
        var insights: [Insight] = []
        
        let currentBankroll = metrics.totalProfit
        let averageBuyIn = sessions.reduce(0) { $0 + $1.buyIn } / Double(sessions.count)
        let buyInRatio = currentBankroll / averageBuyIn
        
        if buyInRatio < 20 && currentBankroll > 0 {
            insights.append(Insight(
                type: .bankrollManagement,
                priority: .high,
                title: "Bankroll Management Warning",
                message: "Your current bankroll of $\(String(format: "%.0f", currentBankroll)) is only \(String(format: "%.1f", buyInRatio)) buy-ins for your average stake.",
                actionableRecommendation: "Consider playing lower stakes until you build up to at least 30 buy-ins for proper bankroll management.",
                confidence: 0.90,
                relevantData: ["bankroll": currentBankroll, "buyin_ratio": buyInRatio]
            ))
        }
        
        let largestLoss = sessions.map { $0.profit }.min() ?? 0
        if abs(largestLoss) > averageBuyIn * 3 {
            insights.append(Insight(
                type: .bankrollManagement,
                priority: .medium,
                title: "Large Loss Alert",
                message: "Your largest single session loss was $\(String(format: "%.0f", abs(largestLoss))), which is \(String(format: "%.1f", abs(largestLoss) / averageBuyIn))x your average buy-in.",
                actionableRecommendation: "Set stop-loss limits to prevent large losses. Consider a maximum loss of 3 buy-ins per session.",
                confidence: 0.80,
                relevantData: ["largest_loss": largestLoss, "loss_ratio": abs(largestLoss) / averageBuyIn]
            ))
        }
        
        return insights
    }
    
    private func analyzeVariance(sessions: [PokerSession], metrics: PerformanceMetrics) async -> [Insight] {
        var insights: [Insight] = []
        
        let coefficientOfVariation = metrics.standardDeviation / abs(metrics.averageHourlyRate)
        
        if coefficientOfVariation > 2.0 {
            insights.append(Insight(
                type: .varianceAnalysis,
                priority: .medium,
                title: "High Variance Detected",
                message: "Your results show high variance with a standard deviation of $\(String(format: "%.0f", metrics.standardDeviation)).",
                actionableRecommendation: "Focus on consistent, solid play rather than high-risk situations. Consider playing more volume to smooth out variance.",
                confidence: 0.75,
                relevantData: ["std_deviation": metrics.standardDeviation, "coefficient_variation": coefficientOfVariation]
            ))
        }
        
        return insights
    }
    
    private func analyzeSessionOptimization(sessions: [PokerSession], metrics: PerformanceMetrics) async -> [Insight] {
        var insights: [Insight] = []
        
        let sessionLengths = sessions.map { $0.duration / 3600 }
        let averageLength = sessionLengths.reduce(0, +) / Double(sessionLengths.count)
        
        let profitsByLength = Dictionary(grouping: sessions) { session in
            Int(session.duration / 3600)
        }.mapValues { sessions in
            sessions.reduce(0) { $0 + $1.profit } / Double(sessions.count)
        }
        
        if let optimalLength = profitsByLength.max(by: { $0.value < $1.value }) {
            if abs(Double(optimalLength.key) - averageLength) > 1.0 {
                insights.append(Insight(
                    type: .sessionOptimization,
                    priority: .medium,
                    title: "Session Length Optimization",
                    message: "Your most profitable sessions average \(optimalLength.key) hours, but you typically play \(String(format: "%.1f", averageLength)) hours.",
                    actionableRecommendation: "Try adjusting your session length to around \(optimalLength.key) hours for optimal results.",
                    confidence: 0.70,
                    relevantData: ["optimal_length": Double(optimalLength.key), "current_average": averageLength]
                ))
            }
        }
        
        return insights
    }
    
    private func analyzeHourlyPerformance(sessions: [PokerSession]) -> [Int: Double] {
        let hourlyData = Dictionary(grouping: sessions) { session in
            Calendar.current.component(.hour, from: session.date)
        }.mapValues { sessions in
            sessions.reduce(0) { $0 + $1.profit } / Double(sessions.count)
        }
        
        return hourlyData
    }
}