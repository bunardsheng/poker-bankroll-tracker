import SwiftUI
import Charts

struct StakesBreakdownView: View {
    let data: AnalyticsData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance by Stakes")
                .font(.headline)
                .padding(.horizontal)
            
            if stakesData.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 16) {
                    barChartView
                    detailsListView
                }
            }
        }
    }
    
    private var stakesData: [StakesData] {
        let grouped = data.sessionsByStakes()
        return grouped.map { stakes, sessions in
            let profit = sessions.reduce(0) { $0 + $1.profit }
            let hours = sessions.reduce(0) { $0 + $1.duration } / 3600
            return StakesData(
                stakes: stakes,
                sessions: sessions,
                profit: profit,
                hours: hours,
                sessionCount: sessions.count
            )
        }.sorted { $0.stakes.bigBlind < $1.stakes.bigBlind }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 36))
                .foregroundColor(.gray)
            
            Text("No stakes data available")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
    }
    
    private var barChartView: some View {
        Chart(stakesData) { data in
            BarMark(
                x: .value("Stakes", data.stakes.description),
                y: .value("Profit", data.profit)
            )
            .foregroundStyle(data.profit >= 0 ? .green : .red)
            .cornerRadius(4)
        }
        .frame(height: 120)
        .padding(.horizontal)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(formatCurrency(doubleValue))
                            .font(.caption2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let stringValue = value.as(String.self) {
                        Text(stringValue)
                            .font(.caption2)
                            .rotationEffect(.degrees(-45))
                    }
                }
            }
        }
    }
    
    private var detailsListView: some View {
        VStack(spacing: 8) {
            ForEach(stakesData) { stakesInfo in
                stakesRow(stakesInfo)
            }
        }
        .padding(.horizontal)
    }
    
    private func stakesRow(_ stakesInfo: StakesData) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(stakesInfo.stakes.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(stakesInfo.sessionCount) sessions • \(String(format: "%.1f", stakesInfo.hours))h")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(stakesInfo.profit))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(stakesInfo.profit >= 0 ? .green : .red)
                
                if stakesInfo.hours > 0 {
                    Text("\(formatCurrency(stakesInfo.hourlyRate))/hr")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
                .opacity(0.5)
        )
        .padding(.horizontal, 4)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

struct StakesData: Identifiable {
    let id = UUID()
    let stakes: Stakes
    let sessions: [PokerSession]
    let profit: Double
    let hours: Double
    let sessionCount: Int
    
    var hourlyRate: Double {
        hours > 0 ? profit / hours : 0
    }
}

#Preview {
    StakesBreakdownView(data: AnalyticsData(sessions: []))
}