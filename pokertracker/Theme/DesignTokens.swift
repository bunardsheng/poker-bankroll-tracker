import SwiftUI

struct DesignTokens {
    
    struct Colors {
        static let neonTeal = Color(red: 0.0, green: 0.8, blue: 0.8)
        static let electricPurple = Color(red: 0.5, green: 0.0, blue: 1.0)
        static let darkBackground = Color(red: 0.06, green: 0.08, blue: 0.12)
        static let cardBackground = Color(red: 0.1, green: 0.12, blue: 0.16)
        static let surfaceBackground = Color(red: 0.14, green: 0.16, blue: 0.20)
        
        static let textPrimary = Color.white
        static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.7)
        static let textMuted = Color(red: 0.5, green: 0.5, blue: 0.5)
        
        static let success = Color(red: 0.0, green: 0.8, blue: 0.4)
        static let error = Color(red: 1.0, green: 0.3, blue: 0.3)
        static let warning = Color(red: 1.0, green: 0.7, blue: 0.0)
        
        static let accentGradient = LinearGradient(
            colors: [neonTeal, electricPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let backgroundGradient = LinearGradient(
            colors: [darkBackground, Color(red: 0.04, green: 0.06, blue: 0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    struct Typography {
        static let mono = "SF Mono"
        static let display = "SF Pro Display"
        static let text = "SF Pro Text"
        
        static let largeTitle = Font.custom(display, size: 34, relativeTo: .largeTitle).weight(.bold)
        static let title1 = Font.custom(display, size: 28, relativeTo: .title).weight(.semibold)
        static let title2 = Font.custom(display, size: 22, relativeTo: .title2).weight(.semibold)
        static let title3 = Font.custom(display, size: 20, relativeTo: .title3).weight(.medium)
        
        static let headline = Font.custom(text, size: 17, relativeTo: .headline).weight(.semibold)
        static let body = Font.custom(text, size: 17, relativeTo: .body)
        static let callout = Font.custom(text, size: 16, relativeTo: .callout)
        static let subheadline = Font.custom(text, size: 15, relativeTo: .subheadline)
        static let footnote = Font.custom(text, size: 13, relativeTo: .footnote)
        static let caption = Font.custom(text, size: 12, relativeTo: .caption)
        static let caption2 = Font.custom(text, size: 11, relativeTo: .caption2)
        
        static let monoLarge = Font.custom(mono, size: 20, relativeTo: .title3).weight(.medium)
        static let monoBody = Font.custom(mono, size: 17, relativeTo: .body)
        static let monoSmall = Font.custom(mono, size: 15, relativeTo: .subheadline)
        static let monoCaption = Font.custom(mono, size: 13, relativeTo: .footnote)
    }
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let round: CGFloat = 999
    }
    
    struct Shadow {
        static let subtle = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.2)
        static let strong = Color.black.opacity(0.3)
        
        static let glow = Color.white.opacity(0.1)
        static let neonGlow = DesignTokens.Colors.neonTeal.opacity(0.3)
        static let purpleGlow = DesignTokens.Colors.electricPurple.opacity(0.3)
    }
    
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        
        static let pulse = SwiftUI.Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        static let bounce = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)
    }
}