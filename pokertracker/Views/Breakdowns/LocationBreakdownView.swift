import SwiftUI
import Charts

struct LocationBreakdownView: View {
    let data: AnalyticsData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance by Location")
                .font(.headline)
                .padding(.horizontal)
            
            if locationData.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 16) {
                    donutChartView
                    detailsListView
                }
            }
        }
    }
    
    private var locationData: [LocationData] {
        let grouped = data.sessionsByLocation()
        return grouped.map { location, sessions in
            let profit = sessions.reduce(0) { $0 + $1.profit }
            let hours = sessions.reduce(0) { $0 + $1.duration } / 3600
            return LocationData(
                location: location,
                sessions: sessions,
                profit: profit,
                hours: hours,
                sessionCount: sessions.count
            )
        }.sorted { $0.profit > $1.profit }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.circle")
                .font(.system(size: 36))
                .foregroundColor(.gray)
            
            Text("No location data available")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
    }
    
    private var donutChartView: some View {
        Chart(locationData) { data in
            SectorMark(
                angle: .value("Profit", abs(data.profit) + 1),
                innerRadius: .ratio(0.6),
                angularInset: 1.5
            )
            .foregroundStyle(colorForLocation(data.location))
            .cornerRadius(2)
        }
        .frame(height: 120)
        .padding(.horizontal)
    }
    
    private var detailsListView: some View {
        VStack(spacing: 8) {
            ForEach(locationData) { locationInfo in
                locationRow(locationInfo)
            }
        }
        .padding(.horizontal)
    }
    
    private func locationRow(_ locationInfo: LocationData) -> some View {
        HStack {
            Circle()
                .fill(colorForLocation(locationInfo.location))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(locationInfo.location)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text("\(locationInfo.sessionCount) sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.1f", locationInfo.hours))h")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(locationInfo.profit))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(locationInfo.profit >= 0 ? .green : .red)
                
                if locationInfo.hours > 0 {
                    Text("\(formatCurrency(locationInfo.hourlyRate))/hr")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func colorForLocation(_ location: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .teal]
        let hash = location.hashValue
        return colors[abs(hash) % colors.count]
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

struct LocationData: Identifiable {
    let id = UUID()
    let location: String
    let sessions: [PokerSession]
    let profit: Double
    let hours: Double
    let sessionCount: Int
    
    var hourlyRate: Double {
        hours > 0 ? profit / hours : 0
    }
}

#Preview {
    LocationBreakdownView(data: AnalyticsData(sessions: []))
}