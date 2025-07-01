import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var dataManager = AnalyticsDataManager.shared
    @State private var selectedTimeframe: Timeframe = .all
    @State private var showingFilters = false
    @State private var selectedMetric: Metric = .profit
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    summaryCardsView
                    
                    chartSelectorView
                    
                    switch selectedMetric {
                    case .profit:
                        BankrollProgressionChart(data: dataManager.analyticsData)
                    case .hourlyRate:
                        HourlyRateChart(data: dataManager.analyticsData)
                    case .sessionCount:
                        SessionCountChart(data: dataManager.analyticsData)
                    }
                    
                    breakdownSection
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Filters") {
                        showingFilters = true
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(dataManager: dataManager)
            }
        }
    }
    
    private var summaryCardsView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            SummaryCard(
                title: "Total Profit",
                value: formatCurrency(dataManager.analyticsData.totalProfit),
                color: dataManager.analyticsData.totalProfit >= 0 ? .green : .red
            )
            
            SummaryCard(
                title: "Sessions",
                value: "\(dataManager.analyticsData.totalSessions)",
                color: .blue
            )
            
            SummaryCard(
                title: "Hourly Rate",
                value: formatCurrency(dataManager.analyticsData.overallHourlyRate),
                color: dataManager.analyticsData.overallHourlyRate >= 0 ? .green : .red
            )
            
            SummaryCard(
                title: "Total Hours",
                value: String(format: "%.1f", dataManager.analyticsData.totalHours),
                color: .orange
            )
        }
    }
    
    private var chartSelectorView: some View {
        HStack {
            Text("View:")
                .font(.headline)
            
            Picker("Metric", selection: $selectedMetric) {
                ForEach(Metric.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.horizontal)
    }
    
    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Breakdown")
                .font(.title2)
                .fontWeight(.semibold)
            
            TabView {
                GameTypeBreakdownView(data: dataManager.analyticsData)
                    .tabItem { Text("Game Type") }
                
                StakesBreakdownView(data: dataManager.analyticsData)
                    .tabItem { Text("Stakes") }
                
                LocationBreakdownView(data: dataManager.analyticsData)
                    .tabItem { Text("Location") }
                
                MonthlyBreakdownView(data: dataManager.analyticsData)
                    .tabItem { Text("Monthly") }
            }
            .frame(height: 300)
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

enum Timeframe: String, CaseIterable {
    case week = "1W"
    case month = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case year = "1Y"
    case all = "All"
}

enum Metric: String, CaseIterable {
    case profit = "Profit"
    case hourlyRate = "Hourly Rate"
    case sessionCount = "Sessions"
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

class AnalyticsDataManager: ObservableObject {
    static let shared = AnalyticsDataManager()
    
    @Published var analyticsData: AnalyticsData
    @Published var appliedFilters: FilterSettings = FilterSettings()
    
    private let allSessions: [PokerSession]
    
    private init() {
        self.allSessions = AnalyticsDataManager.generateSampleData()
        self.analyticsData = AnalyticsData(sessions: allSessions)
    }
    
    func applyFilters(_ filters: FilterSettings) {
        self.appliedFilters = filters
        
        let filteredSessions = allSessions.filter { session in
            if let dateRange = filters.dateRange {
                guard dateRange.contains(session.date) else { return false }
            }
            
            if !filters.selectedGameTypes.isEmpty {
                guard filters.selectedGameTypes.contains(session.gameType) else { return false }
            }
            
            if !filters.selectedStakes.isEmpty {
                guard filters.selectedStakes.contains(session.stakes) else { return false }
            }
            
            if !filters.selectedLocations.isEmpty {
                guard filters.selectedLocations.contains(session.location) else { return false }
            }
            
            return true
        }
        
        self.analyticsData = AnalyticsData(sessions: filteredSessions)
    }
    
    private static func generateSampleData() -> [PokerSession] {
        let calendar = Calendar.current
        let now = Date()
        var sessions: [PokerSession] = []
        
        for i in 0..<50 {
            let date = calendar.date(byAdding: .day, value: -i * 3, to: now) ?? now
            let startTime = calendar.date(byAdding: .hour, value: -8, to: date) ?? date
            let duration = Double.random(in: 2...8) * 3600
            let endTime = startTime.addingTimeInterval(duration)
            
            let gameTypes = GameType.allCases
            let stakes = Stakes.common
            let locations = ["Casino A", "Casino B", "Home Game", "Online"]
            
            let buyIn = Double.random(in: 100...1000)
            let profitRange = Double.random(in: -500...800)
            let cashOut = buyIn + profitRange
            
            let session = PokerSession(
                date: date,
                startTime: startTime,
                endTime: endTime,
                gameType: gameTypes.randomElement() ?? .nlhe,
                stakes: stakes.randomElement() ?? Stakes(smallBlind: 1, bigBlind: 2),
                location: locations.randomElement() ?? "Casino A",
                buyIn: buyIn,
                cashOut: cashOut,
                notes: i % 5 == 0 ? "Good session, played well" : nil
            )
            
            sessions.append(session)
        }
        
        return sessions.sorted { $0.date < $1.date }
    }
}

struct FilterSettings {
    var dateRange: ClosedRange<Date>?
    var selectedGameTypes: Set<GameType> = []
    var selectedStakes: Set<Stakes> = []
    var selectedLocations: Set<String> = []
}

#Preview {
    AnalyticsView()
}