import SwiftUI
import Charts

struct HourlyRateChart: View {
    let data: AnalyticsData
    @State private var selectedSession: PokerSession?
    @State private var showTrendLine: Bool = true
    
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
                Text("Hourly Rate Analysis")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Track your hourly win rate over time")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("Trend", isOn: $showTrendLine)
                .toggleStyle(SwitchToggleStyle())
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No hourly data available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add poker sessions to analyze your hourly win rate")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
    }
    
    private var chartView: some View {
        VStack(spacing: 12) {
            Chart {
                ForEach(data.sessions) { session in
                    PointMark(
                        x: .value("Date", session.date),
                        y: .value("Hourly Rate", session.hourlyRate)
                    )
                    .foregroundStyle(pointColor(for: session.hourlyRate))
                    .symbolSize(selectedSession?.id == session.id ? 150 : 50)
                    .opacity(selectedSession?.id == session.id ? 1.0 : 0.7)
                }
                
                if showTrendLine {
                    ForEach(trendLineData, id: \.date) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Trend", point.hourlyRate)
                        )
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    }
                }
                
                RuleMark(y: .value("Break Even", 0))
                    .foregroundStyle(.gray.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [2, 2]))
            }
            .frame(height: 250)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            updateSelectedSession(at: location, geometry: geometry, chartProxy: chartProxy)
                        }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(formatCurrency(doubleValue))
                                .font(.caption)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            
            if let selectedSession = selectedSession {
                selectedSessionDetails(selectedSession)
            } else {
                summaryDetails
            }
        }
    }
    
    private var trendLineData: [TrendPoint] {
        let sessions = data.sessions.sorted { $0.date < $1.date }
        guard sessions.count > 1 else { return [] }
        
        let windowSize = min(10, sessions.count)
        var trendPoints: [TrendPoint] = []
        
        for i in windowSize..<sessions.count {
            let window = Array(sessions[(i-windowSize)..<i])
            let avgHourlyRate = window.map { $0.hourlyRate }.reduce(0, +) / Double(window.count)
            
            trendPoints.append(TrendPoint(
                date: sessions[i].date,
                hourlyRate: avgHourlyRate
            ))
        }
        
        return trendPoints
    }
    
    private func pointColor(for hourlyRate: Double) -> Color {
        if hourlyRate > 20 {
            return .green
        } else if hourlyRate > 0 {
            return .blue
        } else if hourlyRate > -20 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func selectedSessionDetails(_ session: PokerSession) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Session Details")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDate(session.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(session.gameType.shortName) • \(session.stakes.description)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(session.hourlyRate) + "/hr")
                        .font(.headline)
                        .foregroundColor(pointColor(for: session.hourlyRate))
                    
                    Text(formatCurrency(session.profit) + " • \(String(format: "%.1f", session.duration/3600))h")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    private var summaryDetails: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Best Session")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let bestSession = data.sessions.max(by: { $0.hourlyRate < $1.hourlyRate }) {
                    Text(formatCurrency(bestSession.hourlyRate) + "/hr")
                        .font(.headline)
                        .foregroundColor(.green)
                } else {
                    Text("--")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .center) {
                Text("Average")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formatCurrency(data.overallHourlyRate) + "/hr")
                    .font(.headline)
                    .foregroundColor(data.overallHourlyRate >= 0 ? .green : .red)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Worst Session")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let worstSession = data.sessions.min(by: { $0.hourlyRate < $1.hourlyRate }) {
                    Text(formatCurrency(worstSession.hourlyRate) + "/hr")
                        .font(.headline)
                        .foregroundColor(.red)
                } else {
                    Text("--")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func updateSelectedSession(at location: CGPoint, geometry: GeometryProxy, chartProxy: ChartProxy) {
        let xPosition = location.x - geometry[chartProxy.plotAreaFrame].origin.x
        
        if let date: Date = chartProxy.value(atX: xPosition) {
            selectedSession = data.sessions.min(by: { session in
                abs(session.date.timeIntervalSince(date))
            })
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct TrendPoint {
    let date: Date
    let hourlyRate: Double
}

#Preview {
    HourlyRateChart(data: AnalyticsData(sessions: []))
}