import SwiftUI

struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    let intensity: Double
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(intensity), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(intensity * 0.7), radius: radius * 0.7, x: 0, y: 0)
            .shadow(color: color.opacity(intensity * 0.4), radius: radius * 0.4, x: 0, y: 0)
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    let color: Color
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? scale : 1.0)
            .animation(DesignTokens.Animation.pulse, value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

struct NeonBorder: ViewModifier {
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DesignTokens.Colors.accentGradient, lineWidth: lineWidth)
                    .modifier(GlowEffect(
                        color: DesignTokens.Colors.neonTeal,
                        radius: 4,
                        intensity: 0.6
                    ))
            )
    }
}

struct PokerCard: ViewModifier {
    let isHighlighted: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .fill(DesignTokens.Colors.cardBackground)
                    .modifier(GlowEffect(
                        color: isHighlighted ? DesignTokens.Colors.neonTeal : DesignTokens.Shadow.glow,
                        radius: isHighlighted ? 8 : 2,
                        intensity: isHighlighted ? 0.8 : 0.3
                    ))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .stroke(
                        isHighlighted ? DesignTokens.Colors.neonTeal.opacity(0.5) : Color.clear,
                        lineWidth: 1
                    )
            )
    }
}

struct CommandCenterButton: ViewModifier {
    @State private var isPressed = false
    let style: ButtonStyle
    
    enum ButtonStyle {
        case primary, secondary, accent
        
        var backgroundColor: Color {
            switch self {
            case .primary: return DesignTokens.Colors.neonTeal
            case .secondary: return DesignTokens.Colors.surfaceBackground
            case .accent: return DesignTokens.Colors.electricPurple
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return DesignTokens.Colors.darkBackground
            case .secondary: return DesignTokens.Colors.textPrimary
            case .accent: return DesignTokens.Colors.textPrimary
            }
        }
        
        var glowColor: Color {
            switch self {
            case .primary: return DesignTokens.Colors.neonTeal
            case .secondary: return DesignTokens.Colors.textSecondary
            case .accent: return DesignTokens.Colors.electricPurple
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                    .fill(style.backgroundColor)
                    .modifier(GlowEffect(
                        color: style.glowColor,
                        radius: isPressed ? 6 : 3,
                        intensity: isPressed ? 0.9 : 0.5
                    ))
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(DesignTokens.Animation.quick, value: isPressed)
            .onTapGesture {
                withAnimation(DesignTokens.Animation.quick) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(DesignTokens.Animation.quick) {
                        isPressed = false
                    }
                }
            }
    }
}

struct MetricDisplay: View {
    let title: String
    let value: String
    let trend: TrendDirection?
    let isHighlighted: Bool
    
    enum TrendDirection {
        case up, down, neutral
        
        var color: Color {
            switch self {
            case .up: return DesignTokens.Colors.success
            case .down: return DesignTokens.Colors.error
            case .neutral: return DesignTokens.Colors.textSecondary
            }
        }
        
        var symbol: String {
            switch self {
            case .up: return "↗"
            case .down: return "↘"
            case .neutral: return "→"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(DesignTokens.Typography.caption)
                .foregroundColor(DesignTokens.Colors.textSecondary)
            
            HStack(alignment: .bottom, spacing: DesignTokens.Spacing.xs) {
                Text(value)
                    .font(DesignTokens.Typography.monoLarge)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                if let trend = trend {
                    Text(trend.symbol)
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(trend.color)
                        .modifier(PulseEffect(
                            color: trend.color,
                            scale: 1.1
                        ))
                }
            }
        }
        .padding(DesignTokens.Spacing.md)
        .modifier(PokerCard(isHighlighted: isHighlighted))
    }
}

struct StatusIndicator: View {
    let status: Status
    let label: String?
    
    enum Status {
        case active, inactive, warning, error
        
        var color: Color {
            switch self {
            case .active: return DesignTokens.Colors.success
            case .inactive: return DesignTokens.Colors.textMuted
            case .warning: return DesignTokens.Colors.warning
            case .error: return DesignTokens.Colors.error
            }
        }
    }
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
                .modifier(PulseEffect(
                    color: status.color,
                    scale: 1.2
                ))
            
            if let label = label {
                Text(label)
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
            }
        }
    }
}