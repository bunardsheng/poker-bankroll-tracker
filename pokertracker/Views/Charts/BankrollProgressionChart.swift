import SwiftUI
import Charts

struct BankrollProgressionChart: View {
    let data: AnalyticsData
    @State private var selectedPoint: BankrollPoint?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bankroll Progression")
                .font(.title2)
                .fontWeight(.semibold)
            
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
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No session data available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add some poker sessions to see your bankroll progression")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
    }
    
    private var chartView: some View {
        VStack(spacing: 12) {
            Chart(data.bankrollProgression) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Bankroll", point.bankroll)
                )
                .foregroundStyle(chartColor)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                AreaMark(
                    x: .value("Date", point.date),
                    yStart: .value("Zero", 0),
                    yEnd: .value("Bankroll", point.bankroll)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [chartColor.opacity(0.3), chartColor.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                if let selectedPoint = selectedPoint, selectedPoint.id == point.id {
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Bankroll", point.bankroll)
                    )
                    .foregroundStyle(chartColor)
                    .symbolSize(100)
                }
            }
            .frame(height: 250)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            updateSelectedPoint(at: location, geometry: geometry, chartProxy: chartProxy)
                        }
                }
            }
            .chartAngleSelection(value: .constant(nil))
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
            
            if let selectedPoint = selectedPoint {
                selectedPointDetails(selectedPoint)
            } else {
                summaryDetails
            }
        }
    }
    
    private var chartColor: Color {
        let finalProfit = data.bankrollProgression.last?.bankroll ?? 0
        return finalProfit >= 0 ? .green : .red
    }
    
    private func selectedPointDetails(_ point: BankrollPoint) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Selected Point")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(formatDate(point.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(formatCurrency(point.bankroll))
                        .font(.headline)
                        .foregroundColor(point.bankroll >= 0 ? .green : .red)
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
                Text("Total Sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(data.totalSessions)")
                    .font(.headline)
            }
            
            Spacer()
            
            VStack(alignment: .center) {
                Text("Current P&L")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formatCurrency(data.totalProfit))
                    .font(.headline)
                    .foregroundColor(data.totalProfit >= 0 ? .green : .red)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Avg Session")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formatCurrency(data.avgSessionProfit))
                    .font(.headline)
                    .foregroundColor(data.avgSessionProfit >= 0 ? .green : .red)
            }
        }
        .padding(.horizontal)
    }
    
    private func updateSelectedPoint(at location: CGPoint, geometry: GeometryProxy, chartProxy: ChartProxy) {
        let xPosition = location.x - geometry[chartProxy.plotAreaFrame].origin.x
        
        if let date: Date = chartProxy.value(atX: xPosition) {
            selectedPoint = data.bankrollProgression.min(by: { point in
                abs(point.date.timeIntervalSince(date))
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

#Preview {
    BankrollProgressionChart(data: AnalyticsData(sessions: []))
}