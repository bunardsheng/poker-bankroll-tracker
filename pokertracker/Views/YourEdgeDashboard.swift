import SwiftUI

struct YourEdgeDashboard: View {
    @StateObject private var aiInsightsService = AIInsightsService()
    @State private var currentInsightIndex = 0
    @State private var rotationTimer: Timer?
    @State private var sessions: [PokerSession] = []
    
    let rotationInterval: TimeInterval = 5.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeaderSection()
                
                if aiInsightsService.isGeneratingInsights {
                    LoadingSection()
                } else if aiInsightsService.insights.isEmpty {
                    EmptyStateSection()
                } else {
                    InsightsSection()
                }
                
                QuickActionsSection()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Your Edge")
        .onAppear {
            loadSampleData()
            Task {
                await aiInsightsService.generateInsights(from: sessions)
            }
            startRotationTimer()
        }
        .onDisappear {
            stopRotationTimer()
        }
    }
    
    private func HeaderSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("AI Insights")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Powered by advanced analytics")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: refreshInsights) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .disabled(aiInsightsService.isGeneratingInsights)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private func LoadingSection() -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Analyzing your poker data...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private func EmptyStateSection() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("No Insights Available")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Play more sessions to unlock AI-powered insights and recommendations.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private func InsightsSection() -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Priority Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if aiInsightsService.insights.count > 1 {
                    PageIndicator(
                        currentIndex: currentInsightIndex,
                        total: min(aiInsightsService.insights.count, 3)
                    )
                }
            }
            
            if !aiInsightsService.insights.isEmpty {
                TabView(selection: $currentInsightIndex) {
                    ForEach(Array(aiInsightsService.insights.prefix(3).enumerated()), id: \.offset) { index, insight in
                        InsightCardView(insight: insight)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 200)
                
                if aiInsightsService.insights.count > 3 {
                    NavigationLink(destination: AllInsightsView(insights: aiInsightsService.insights)) {
                        HStack {
                            Text("View All \(aiInsightsService.insights.count) Insights")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                }
            }
        }
    }
    
    private func QuickActionsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    title: "Add Session",
                    icon: "plus.circle.fill",
                    color: .green
                ) {
                    // Add session action
                }
                
                QuickActionButton(
                    title: "View Stats",
                    icon: "chart.bar.fill",
                    color: .blue
                ) {
                    // View stats action
                }
                
                QuickActionButton(
                    title: "Export Data",
                    icon: "square.and.arrow.up.fill",
                    color: .purple
                ) {
                    // Export data action
                }
                
                QuickActionButton(
                    title: "Settings",
                    icon: "gear.fill",
                    color: .gray
                ) {
                    // Settings action
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private func startRotationTimer() {
        guard aiInsightsService.insights.count > 1 else { return }
        
        rotationTimer = Timer.scheduledTimer(withTimeInterval: rotationInterval, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentInsightIndex = (currentInsightIndex + 1) % min(aiInsightsService.insights.count, 3)
            }
        }
    }
    
    private func stopRotationTimer() {
        rotationTimer?.invalidate()
        rotationTimer = nil
    }
    
    private func refreshInsights() {
        Task {
            await aiInsightsService.generateInsights(from: sessions)
        }
    }
    
    private func loadSampleData() {
        // Sample data for demonstration
        sessions = [
            PokerSession(date: Date().addingTimeInterval(-86400 * 10), gameType: .nlhe, stakes: "1/2", buyIn: 200, cashOut: 350, duration: 14400, location: "Casino A", notes: nil),
            PokerSession(date: Date().addingTimeInterval(-86400 * 8), gameType: .nlhe, stakes: "1/2", buyIn: 200, cashOut: 180, duration: 10800, location: "Casino A", notes: nil),
            PokerSession(date: Date().addingTimeInterval(-86400 * 6), gameType: .nlhe, stakes: "1/2", buyIn: 200, cashOut: 420, duration: 18000, location: "Casino B", notes: nil),
            PokerSession(date: Date().addingTimeInterval(-86400 * 4), gameType: .nlhe, stakes: "1/2", buyIn: 200, cashOut: 160, duration: 7200, location: "Casino A", notes: nil),
            PokerSession(date: Date().addingTimeInterval(-86400 * 2), gameType: .nlhe, stakes: "1/2", buyIn: 200, cashOut: 240, duration: 12600, location: "Casino C", notes: nil),
            PokerSession(date: Date().addingTimeInterval(-86400 * 1), gameType: .nlhe, stakes: "1/2", buyIn: 200, cashOut: 150, duration: 9000, location: "Casino A", notes: nil)
        ]
    }
}

struct PageIndicator: View {
    let currentIndex: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AllInsightsView: View {
    let insights: [Insight]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(insights) { insight in
                    InsightCardView(insight: insight)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("All Insights")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationView {
        YourEdgeDashboard()
    }
}