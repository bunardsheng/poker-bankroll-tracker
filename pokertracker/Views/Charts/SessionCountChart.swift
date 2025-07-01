import SwiftUI
import Charts

struct SessionCountChart: View {
    let data: AnalyticsData
    @State private var selectedPeriod: ChartPeriod = .month
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            
            if data.sessions.isEmpty {
                emptyStateView
            } else {
                chartView
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Session Volume")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Track your playing frequency")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Picker("Period", selection: $selectedPeriod) {
                ForEach(ChartPeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No session data available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add poker sessions to see your playing volume")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
    }
    
    private var chartView: some View {
        VStack(spacing: 12) {
            Chart(chartData) { dataPoint in
                BarMark(
                    x: .value("Period", dataPoint.period),
                    y: .value("Sessions", dataPoint.sessionCount)
                )
                .foregroundStyle(barGradient)
                .cornerRadius(4)
                
                LineMark(
                    x: .value("Period", dataPoint.period),
                    y: .value("Sessions", dataPoint.sessionCount)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .symbol(.circle)
                .symbolSize(50)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.caption)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let stringValue = value.as(String.self) {
                            Text(stringValue)
                                .font(.caption)
                                .rotationEffect(.degrees(-45))
                        }
                    }
                }
            }
            
            summaryView
        }
    }
    
    private var chartData: [SessionVolumeData] {
        switch selectedPeriod {
        case .week:
            return weeklyData
        case .month:
            return monthlyData
        case .year:
            return yearlyData
        }
    }
    
    private var weeklyData: [SessionVolumeData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: data.sessions) { session in
            calendar.dateInterval(of: .weekOfYear, for: session.date)?.start ?? session.date
        }
        
        return grouped.map { date, sessions in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return SessionVolumeData(
                period: formatter.string(from: date),
                sessionCount: sessions.count,
                date: date
            )
        }.sorted { $0.date < $1.date }
    }
    
    private var monthlyData: [SessionVolumeData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: data.sessions) { session in
            calendar.dateInterval(of: .month, for: session.date)?.start ?? session.date
        }
        
        return grouped.map { date, sessions in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yy"
            return SessionVolumeData(
                period: formatter.string(from: date),
                sessionCount: sessions.count,
                date: date
            )
        }.sorted { $0.date < $1.date }
    }
    
    private var yearlyData: [SessionVolumeData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: data.sessions) { session in
            calendar.component(.year, from: session.date)
        }
        
        return grouped.map { year, sessions in
            return SessionVolumeData(
                period: "\(year)",
                sessionCount: sessions.count,
                date: calendar.date(from: DateComponents(year: year)) ?? Date()
            )
        }.sorted { $0.date < $1.date }
    }
    
    private var barGradient: LinearGradient {
        LinearGradient(
            colors: [.blue.opacity(0.8), .blue.opacity(0.4)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var summaryView: some View {
        let totalSessions = chartData.reduce(0) { $0 + $1.sessionCount }
        let avgSessions = chartData.isEmpty ? 0 : Double(totalSessions) / Double(chartData.count)
        let maxSessions = chartData.max { $0.sessionCount < $1.sessionCount }?.sessionCount ?? 0
        
        return HStack {
            VStack(alignment: .leading) {
                Text("Total")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(totalSessions)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            VStack(alignment: .center) {
                Text("Average")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(String(format: "%.1f", avgSessions))
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Peak")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(maxSessions)")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal)
    }
}

enum ChartPeriod: String, CaseIterable {
    case week = "Weekly"
    case month = "Monthly"
    case year = "Yearly"
}

struct SessionVolumeData: Identifiable {
    let id = UUID()
    let period: String
    let sessionCount: Int
    let date: Date
}

#Preview {
    SessionCountChart(data: AnalyticsData(sessions: []))
}