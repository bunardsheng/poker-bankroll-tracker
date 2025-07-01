import SwiftUI

extension DesignTokens.Colors {
    static func withAccessibility(baseColor: Color, background: Color = darkBackground) -> Color {
        let contrastRatio = calculateContrastRatio(foreground: baseColor, background: background)
        
        if contrastRatio < 4.5 {
            return adjustColorForContrast(baseColor, background: background)
        }
        return baseColor
    }
    
    private static func calculateContrastRatio(foreground: Color, background: Color) -> Double {
        let fgLuminance = relativeLuminance(color: foreground)
        let bgLuminance = relativeLuminance(color: background)
        
        let lighter = max(fgLuminance, bgLuminance)
        let darker = min(fgLuminance, bgLuminance)
        
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    private static func relativeLuminance(color: Color) -> Double {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let sRGB = [red, green, blue].map { value in
            let val = Double(value)
            return val <= 0.03928 ? val / 12.92 : pow((val + 0.055) / 1.055, 2.4)
        }
        
        return 0.2126 * sRGB[0] + 0.7152 * sRGB[1] + 0.0722 * sRGB[2]
    }
    
    private static func adjustColorForContrast(_ color: Color, background: Color) -> Color {
        let uiColor = UIColor(color)
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let adjustedBrightness = brightness < 0.5 ? min(1.0, brightness + 0.3) : max(0.0, brightness - 0.3)
        
        return Color(UIColor(hue: hue, saturation: saturation, brightness: adjustedBrightness, alpha: alpha))
    }
    
    static var accessibleNeonTeal: Color {
        withAccessibility(baseColor: neonTeal)
    }
    
    static var accessibleElectricPurple: Color {
        withAccessibility(baseColor: electricPurple)
    }
    
    static var accessibleSuccess: Color {
        withAccessibility(baseColor: success)
    }
    
    static var accessibleError: Color {
        withAccessibility(baseColor: error)
    }
    
    static var accessibleWarning: Color {
        withAccessibility(baseColor: warning)
    }
}

struct AccessibleButton: ViewModifier {
    let style: CommandCenterButton.ButtonStyle
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .modifier(CommandCenterButton(style: style))
            .accessibilityLabel(extractText(from: content))
            .accessibilityHint(getHint(for: style))
            .accessibilityAddTraits(isEnabled ? .isButton : [.isButton, .isNotEnabled])
            .opacity(isEnabled ? 1.0 : 0.6)
    }
    
    private func extractText(from content: Content) -> String {
        return ""
    }
    
    private func getHint(for style: CommandCenterButton.ButtonStyle) -> String {
        switch style {
        case .primary: return "Primary action button"
        case .secondary: return "Secondary action button"
        case .accent: return "Accent action button"
        }
    }
}

struct AccessibleMetric: ViewModifier {
    let title: String
    let value: String
    let trend: MetricDisplay.TrendDirection?
    
    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title): \(value)")
            .accessibilityValue(getTrendDescription())
    }
    
    private func getTrendDescription() -> String {
        guard let trend = trend else { return "" }
        switch trend {
        case .up: return "trending up"
        case .down: return "trending down"
        case .neutral: return "stable"
        }
    }
}

extension View {
    func accessibleGlow(color: Color, radius: CGFloat = 4, intensity: Double = 0.6) -> some View {
        self.modifier(GlowEffect(color: color, radius: radius, intensity: intensity))
            .accessibilityHidden(true)
    }
    
    func accessiblePulse(color: Color, scale: CGFloat = 1.1) -> some View {
        self.modifier(PulseEffect(color: color, scale: scale))
            .accessibilityHidden(true)
    }
    
    func commandCenterButton(style: CommandCenterButton.ButtonStyle, isEnabled: Bool = true) -> some View {
        self.modifier(AccessibleButton(style: style, isEnabled: isEnabled))
    }
    
    func pokerCard(isHighlighted: Bool = false) -> some View {
        self.modifier(PokerCard(isHighlighted: isHighlighted))
    }
    
    func neonBorder(cornerRadius: CGFloat = DesignTokens.CornerRadius.md, lineWidth: CGFloat = 1) -> some View {
        self.modifier(NeonBorder(cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
}