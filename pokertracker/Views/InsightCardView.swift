import SwiftUI

struct InsightCardView: View {
    let insight: Insight
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        PriorityIndicator(priority: insight.priority)
                        Text(insight.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        ConfidenceBadge(confidence: insight.confidence)
                    }
                    
                    Text(insight.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            
            Text(insight.message)
                .font(.body)
                .foregroundColor(.primary)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recommended Action")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text(insight.actionableRecommendation)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    if !insight.relevantData.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Key Metrics")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 120))
                            ], spacing: 8) {
                                ForEach(Array(insight.relevantData.keys.sorted()), id: \.self) { key in
                                    MetricChip(
                                        label: key.replacingOccurrences(of: "_", with: " ").capitalized,
                                        value: insight.relevantData[key] ?? 0
                                    )
                                }
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .slide))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(priorityColor, lineWidth: 1)
        )
    }
    
    private var priorityColor: Color {
        switch insight.priority {
        case .critical:
            return .red
        case .high:
            return .orange
        case .medium:
            return .yellow
        case .low:
            return .green
        }
    }
}

struct PriorityIndicator: View {
    let priority: InsightPriority
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
    }
    
    private var color: Color {
        switch priority {
        case .critical:
            return .red
        case .high:
            return .orange
        case .medium:
            return .yellow
        case .low:
            return .green
        }
    }
}

struct ConfidenceBadge: View {
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(confidenceColor)
                .font(.caption2)
            Text("\(Int(confidence * 100))%")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(confidenceColor)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(confidenceColor.opacity(0.1))
        )
    }
    
    private var confidenceColor: Color {
        if confidence >= 0.8 {
            return .green
        } else if confidence >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

struct MetricChip: View {
    let label: String
    let value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
            Text(formatValue(value))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else if abs(value) < 1 {
            return String(format: "%.2f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        InsightCardView(insight: Insight(
            type: .streakAnalysis,
            priority: .critical,
            title: "Extended Losing Streak",
            message: "You're currently on a 5-session losing streak. Your worst streak was 7 sessions.",
            actionableRecommendation: "Consider taking a break, reviewing your recent play, or dropping down in stakes until the streak breaks.",
            confidence: 0.95,
            relevantData: ["current_streak": -5, "worst_streak": 7]
        ))
        
        InsightCardView(insight: Insight(
            type: .timeBasedPerformance,
            priority: .medium,
            title: "Peak Performance Time",
            message: "You perform best around 19:00 with an average profit of $150.",
            actionableRecommendation: "Schedule more sessions during your peak hours (19:00-21:00) to maximize profits.",
            confidence: 0.75,
            relevantData: ["best_hour": 19, "best_hour_profit": 150]
        ))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}