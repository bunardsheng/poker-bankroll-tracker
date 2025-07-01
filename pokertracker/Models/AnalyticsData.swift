import Foundation

struct AnalyticsData {
    let sessions: [PokerSession]
    
    init(sessions: [PokerSession]) {
        self.sessions = sessions.sorted { $0.date < $1.date }
    }
    
    var totalProfit: Double {
        sessions.reduce(0) { $0 + $1.profit }
    }
    
    var totalSessions: Int {
        sessions.count
    }
    
    var avgSessionProfit: Double {
        totalSessions > 0 ? totalProfit / Double(totalSessions) : 0
    }
    
    var totalHours: Double {
        sessions.reduce(0) { $0 + $1.duration } / 3600
    }
    
    var overallHourlyRate: Double {
        totalHours > 0 ? totalProfit / totalHours : 0
    }
    
    var bankrollProgression: [BankrollPoint] {
        var runningTotal: Double = 0
        return sessions.map { session in
            runningTotal += session.profit
            return BankrollPoint(date: session.date, bankroll: runningTotal)
        }
    }
    
    func sessionsByGameType() -> [GameType: [PokerSession]] {
        Dictionary(grouping: sessions, by: { $0.gameType })
    }
    
    func sessionsByStakes() -> [Stakes: [PokerSession]] {
        Dictionary(grouping: sessions, by: { $0.stakes })
    }
    
    func sessionsByLocation() -> [String: [PokerSession]] {
        Dictionary(grouping: sessions, by: { $0.location })
    }
    
    func monthlyBreakdown() -> [MonthlyData] {
        let grouped = Dictionary(grouping: sessions) { session in
            Calendar.current.dateInterval(of: .month, for: session.date)?.start ?? session.date
        }
        
        return grouped.map { date, sessions in
            MonthlyData(
                month: date,
                sessions: sessions,
                profit: sessions.reduce(0) { $0 + $1.profit },
                hours: sessions.reduce(0) { $0 + $1.duration } / 3600
            )
        }.sorted { $0.month < $1.month }
    }
    
    func yearlyBreakdown() -> [YearlyData] {
        let grouped = Dictionary(grouping: sessions) { session in
            Calendar.current.component(.year, from: session.date)
        }
        
        return grouped.map { year, sessions in
            YearlyData(
                year: year,
                sessions: sessions,
                profit: sessions.reduce(0) { $0 + $1.profit },
                hours: sessions.reduce(0) { $0 + $1.duration } / 3600
            )
        }.sorted { $0.year < $1.year }
    }
    
    func filteredSessions(
        dateRange: ClosedRange<Date>? = nil,
        gameTypes: Set<GameType>? = nil,
        stakes: Set<Stakes>? = nil,
        locations: Set<String>? = nil
    ) -> AnalyticsData {
        var filtered = sessions
        
        if let dateRange = dateRange {
            filtered = filtered.filter { dateRange.contains($0.date) }
        }
        
        if let gameTypes = gameTypes, !gameTypes.isEmpty {
            filtered = filtered.filter { gameTypes.contains($0.gameType) }
        }
        
        if let stakes = stakes, !stakes.isEmpty {
            filtered = filtered.filter { stakes.contains($0.stakes) }
        }
        
        if let locations = locations, !locations.isEmpty {
            filtered = filtered.filter { locations.contains($0.location) }
        }
        
        return AnalyticsData(sessions: filtered)
    }
}

struct BankrollPoint: Identifiable {
    let id = UUID()
    let date: Date
    let bankroll: Double
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: Date
    let sessions: [PokerSession]
    let profit: Double
    let hours: Double
    
    var sessionCount: Int { sessions.count }
    var hourlyRate: Double { hours > 0 ? profit / hours : 0 }
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: month)
    }
}

struct YearlyData: Identifiable {
    let id = UUID()
    let year: Int
    let sessions: [PokerSession]
    let profit: Double
    let hours: Double
    
    var sessionCount: Int { sessions.count }
    var hourlyRate: Double { hours > 0 ? profit / hours : 0 }
}