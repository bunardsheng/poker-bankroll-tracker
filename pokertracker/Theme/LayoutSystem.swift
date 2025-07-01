import SwiftUI

struct CommandCenterLayout: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignTokens.Colors.backgroundGradient)
            .preferredColorScheme(.dark)
            .environment(\.colorScheme, .dark)
    }
}

struct SectionContainer: ViewModifier {
    let title: String?
    let spacing: CGFloat
    
    init(title: String? = nil, spacing: CGFloat = DesignTokens.Spacing.md) {
        self.title = title
        self.spacing = spacing
    }
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            if let title = title {
                Text(title)
                    .font(DesignTokens.Typography.headline)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .padding(.horizontal, DesignTokens.Spacing.md)
            }
            
            content
        }
    }
}

struct CardGrid<Content: View>: View {
    let columns: Int
    let spacing: CGFloat
    let content: () -> Content
    
    init(columns: Int = 2, spacing: CGFloat = DesignTokens.Spacing.md, @ViewBuilder content: @escaping () -> Content) {
        self.columns = columns
        self.spacing = spacing
        self.content = content
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)
    }
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: spacing) {
            content()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }
}

struct ResponsiveStack<Content: View>: View {
    let horizontalThreshold: CGFloat
    let spacing: CGFloat
    let content: () -> Content
    
    @State private var isHorizontal = false
    
    init(horizontalThreshold: CGFloat = 600, spacing: CGFloat = DesignTokens.Spacing.md, @ViewBuilder content: @escaping () -> Content) {
        self.horizontalThreshold = horizontalThreshold
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if geometry.size.width > horizontalThreshold {
                    HStack(spacing: spacing) {
                        content()
                    }
                } else {
                    VStack(spacing: spacing) {
                        content()
                    }
                }
            }
            .onAppear {
                isHorizontal = geometry.size.width > horizontalThreshold
            }
            .onChange(of: geometry.size.width) { width in
                withAnimation(DesignTokens.Animation.standard) {
                    isHorizontal = width > horizontalThreshold
                }
            }
        }
    }
}

struct FloatingPanel: ViewModifier {
    let padding: CGFloat
    let cornerRadius: CGFloat
    
    init(padding: CGFloat = DesignTokens.Spacing.lg, cornerRadius: CGFloat = DesignTokens.CornerRadius.lg) {
        self.padding = padding
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(DesignTokens.Colors.surfaceBackground)
                    .modifier(GlowEffect(
                        color: DesignTokens.Shadow.glow,
                        radius: 8,
                        intensity: 0.4
                    ))
            )
            .padding(DesignTokens.Spacing.md)
    }
}

struct DashboardMetrics: View {
    let metrics: [MetricData]
    
    struct MetricData {
        let title: String
        let value: String
        let trend: MetricDisplay.TrendDirection?
        let isHighlighted: Bool
        
        init(title: String, value: String, trend: MetricDisplay.TrendDirection? = nil, isHighlighted: Bool = false) {
            self.title = title
            self.value = value
            self.trend = trend
            self.isHighlighted = isHighlighted
        }
    }
    
    var body: some View {
        CardGrid(columns: 2) {
            ForEach(Array(metrics.enumerated()), id: \.offset) { index, metric in
                MetricDisplay(
                    title: metric.title,
                    value: metric.value,
                    trend: metric.trend,
                    isHighlighted: metric.isHighlighted
                )
                .modifier(AccessibleMetric(
                    title: metric.title,
                    value: metric.value,
                    trend: metric.trend
                ))
            }
        }
    }
}

struct StatusBar: View {
    let status: StatusIndicator.Status
    let message: String
    let action: (() -> Void)?
    
    init(status: StatusIndicator.Status, message: String, action: (() -> Void)? = nil) {
        self.status = status
        self.message = message
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            StatusIndicator(status: status, label: nil)
            
            Text(message)
                .font(DesignTokens.Typography.callout)
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let action = action {
                Button("Action") {
                    action()
                }
                .commandCenterButton(style: .secondary)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                .fill(DesignTokens.Colors.cardBackground.opacity(0.7))
                .modifier(GlowEffect(
                    color: status.color,
                    radius: 2,
                    intensity: 0.3
                ))
        )
    }
}

extension View {
    func commandCenterLayout() -> some View {
        self.modifier(CommandCenterLayout())
    }
    
    func sectionContainer(title: String? = nil, spacing: CGFloat = DesignTokens.Spacing.md) -> some View {
        self.modifier(SectionContainer(title: title, spacing: spacing))
    }
    
    func floatingPanel(padding: CGFloat = DesignTokens.Spacing.lg, cornerRadius: CGFloat = DesignTokens.CornerRadius.lg) -> some View {
        self.modifier(FloatingPanel(padding: padding, cornerRadius: cornerRadius))
    }
}