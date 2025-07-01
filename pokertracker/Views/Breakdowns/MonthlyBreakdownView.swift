import SwiftUI
import Charts

struct MonthlyBreakdownView: View {
    let data: AnalyticsData
    @State private var selectedMonth: MonthlyData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Performance")
                .font(.headline)
                .padding(.horizontal)
            
            if monthlyData.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 16) {
                    lineChartView
                    if let selectedMonth = selectedMonth {
                        monthDetailView(selectedMonth)
                    } else {
                        summaryView
                    }
                }
            }
        }
    }
    
    private var monthlyData: [MonthlyData] {
        data.monthlyBreakdown()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 36))
                .foregroundColor(.gray)
            
            Text("No monthly data available")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
    }
    
    private var lineChartView: some View {
        Chart(monthlyData) { monthData in
            LineMark(
                x: .value("Month", monthData.month),
                y: .value("Profit", monthData.profit)
            )
            .foregroundStyle(.blue)
            .lineStyle(StrokeStyle(lineWidth: 3))
            .symbol(.circle)
            .symbolSize(50)
            
            AreaMark(
                x: .value("Month", monthData.month),
                yStart: .value("Zero", 0),
                yEnd: .value("Profit", monthData.profit)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        monthData.profit >= 0 ? .green.opacity(0.3) : .red.opacity(0.3),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            if let selectedMonth = selectedMonth, selectedMonth.id == monthData.id {
                PointMark(
                    x: .value("Month", monthData.month),
                    y: .value("Profit", monthData.profit)
                )
                .foregroundStyle(.blue)
                .symbolSize(100)
            }
        }
        .frame(height: 120)
        .padding(.horizontal)
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        updateSelectedMonth(at: location, geometry: geometry, chartProxy: chartProxy)
                    }
            }
        }
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
            AxisMarks(values: .stride(by: .month)) { value in
                AxisValueLabel(format: .dateTime.month(.abbreviated))
            }
        }
    }
    
    private func monthDetailView(_ month: MonthlyData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Selected: \(month.monthName)")
                    .font(.headline)
                
                Spacer()
                
                Button("Clear") {
                    selectedMonth = nil
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                MetricCard(
                    title: "Profit",
                    value: formatCurrency(month.profit),
                    color: month.profit >= 0 ? .green : .red
                )
                
                MetricCard(
                    title: "Sessions",
                    value: "\(month.sessionCount)",
                    color: .blue
                )
                
                MetricCard(
                    title: "Hours",
                    value: String(format: "%.1f", month.hours),
                    color: .orange
                )
                
                MetricCard(
                    title: "Hourly Rate",
                    value: formatCurrency(month.hourlyRate),
                    color: month.hourlyRate >= 0 ? .green : .red
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var summaryView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Monthly Summary")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                let bestMonth = monthlyData.max { $0.profit < $1.profit }
                let worstMonth = monthlyData.min { $0.profit < $1.profit }
                let avgProfit = monthlyData.isEmpty ? 0 : monthlyData.reduce(0) { $0 + $1.profit } / Double(monthlyData.count)
                let avgSessions = monthlyData.isEmpty ? 0 : monthlyData.reduce(0) { $0 + $1.sessionCount } / monthlyData.count
                
                MetricCard(
                    title: "Best Month",
                    value: formatCurrency(bestMonth?.profit ?? 0),
                    subtitle: bestMonth?.monthName,
                    color: .green
                )
                
                MetricCard(
                    title: "Worst Month",
                    value: formatCurrency(worstMonth?.profit ?? 0),
                    subtitle: worstMonth?.monthName,
                    color: .red
                )
                
                MetricCard(
                    title: "Avg Monthly",
                    value: formatCurrency(avgProfit),
                    color: avgProfit >= 0 ? .green : .red
                )
                
                MetricCard(
                    title: "Avg Sessions",
                    value: "\(avgSessions)",
                    color: .blue
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func updateSelectedMonth(at location: CGPoint, geometry: GeometryProxy, chartProxy: ChartProxy) {
        let xPosition = location.x - geometry[chartProxy.plotAreaFrame].origin.x
        
        if let date: Date = chartProxy.value(atX: xPosition) {
            selectedMonth = monthlyData.min(by: { month in
                abs(month.month.timeIntervalSince(date))
            })
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let color: Color
    
    init(title: String, value: String, subtitle: String? = nil, color: Color) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    MonthlyBreakdownView(data: AnalyticsData(sessions: []))
}