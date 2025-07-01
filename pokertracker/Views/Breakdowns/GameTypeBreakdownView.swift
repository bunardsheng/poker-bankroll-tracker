import SwiftUI
import Charts

struct GameTypeBreakdownView: View {
    let data: AnalyticsData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance by Game Type")
                .font(.headline)
                .padding(.horizontal)
            
            if gameTypeData.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 16) {
                    pieChartView
                    detailsListView
                }
            }
        }
    }
    
    private var gameTypeData: [GameTypeData] {
        let grouped = data.sessionsByGameType()
        return grouped.map { gameType, sessions in
            let profit = sessions.reduce(0) { $0 + $1.profit }
            let hours = sessions.reduce(0) { $0 + $1.duration } / 3600
            return GameTypeData(
                gameType: gameType,
                sessions: sessions,
                profit: profit,
                hours: hours,
                sessionCount: sessions.count
            )
        }.sorted { $0.profit > $1.profit }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "suit.club.fill")
                .font(.system(size: 36))
                .foregroundColor(.gray)
            
            Text("No game data available")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
    }
    
    private var pieChartView: some View {
        Chart(gameTypeData) { data in
            SectorMark(
                angle: .value("Sessions", data.sessionCount),
                innerRadius: .ratio(0.5),
                angularInset: 2
            )
            .foregroundStyle(colorForGameType(data.gameType))
            .cornerRadius(4)
        }
        .frame(height: 120)
        .padding(.horizontal)
    }
    
    private var detailsListView: some View {
        VStack(spacing: 8) {
            ForEach(gameTypeData) { gameData in
                gameTypeRow(gameData)
            }
        }
        .padding(.horizontal)
    }
    
    private func gameTypeRow(_ gameData: GameTypeData) -> some View {
        HStack {
            Circle()
                .fill(colorForGameType(gameData.gameType))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(gameData.gameType.shortName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(gameData.sessionCount) sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(gameData.profit))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(gameData.profit >= 0 ? .green : .red)
                
                if gameData.hours > 0 {
                    Text("\(formatCurrency(gameData.hourlyRate))/hr")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func colorForGameType(_ gameType: GameType) -> Color {
        switch gameType {
        case .nlhe: return .blue
        case .plo: return .green
        case .mixed: return .orange
        case .tournament: return .purple
        case .sitAndGo: return .red
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

struct GameTypeData: Identifiable {
    let id = UUID()
    let gameType: GameType
    let sessions: [PokerSession]
    let profit: Double
    let hours: Double
    let sessionCount: Int
    
    var hourlyRate: Double {
        hours > 0 ? profit / hours : 0
    }
}

#Preview {
    GameTypeBreakdownView(data: AnalyticsData(sessions: []))
}