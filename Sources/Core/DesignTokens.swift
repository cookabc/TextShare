import SwiftUI

// MARK: - Design Token System
// Centralized design tokens for consistent styling across the app

enum DesignTokens {
    
    // MARK: - Spacing
    enum Spacing {
        /// 4pt - Extra small spacing for tight layouts
        static let xs: CGFloat = 4
        /// 8pt - Small spacing between related elements
        static let sm: CGFloat = 8
        /// 12pt - Compact spacing
        static let compact: CGFloat = 12
        /// 16pt - Medium spacing for general use
        static let md: CGFloat = 16
        /// 24pt - Large spacing between sections
        static let lg: CGFloat = 24
        /// 32pt - Extra large spacing for major sections
        static let xl: CGFloat = 32
        /// 48pt - Maximum spacing
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        /// 4pt - Subtle rounding
        static let xs: CGFloat = 4
        /// 6pt - Small buttons, tags
        static let sm: CGFloat = 6
        /// 8pt - Cards, input fields
        static let md: CGFloat = 8
        /// 12pt - Modals, large cards
        static let lg: CGFloat = 12
        /// 16pt - Feature cards
        static let xl: CGFloat = 16
        /// 20pt - Hero elements
        static let xxl: CGFloat = 20
    }
    
    // MARK: - Shadows
    enum Shadow {
        static let subtle = Color.black.opacity(0.05)
        static let light = Color.black.opacity(0.08)
        static let medium = Color.black.opacity(0.12)
        static let strong = Color.black.opacity(0.2)
    }
    
    // MARK: - Animation
    enum Animation {
        /// 0.15s - Quick micro-interactions
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.15)
        /// 0.25s - Standard transitions
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        /// 0.4s - Slower, more noticeable transitions
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.4)
        /// Spring animation for bouncy effects
        static let spring = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.7)
        /// Smooth spring for subtle effects
        static let smoothSpring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
    }
    
    // MARK: - Border Width
    enum BorderWidth {
        /// 1pt - Subtle borders
        static let thin: CGFloat = 1
        /// 2pt - Medium emphasis
        static let medium: CGFloat = 2
        /// 3pt - Strong emphasis
        static let thick: CGFloat = 3
    }
    
    // MARK: - Gradients
    enum Gradient {
        static let primary = LinearGradient(
            colors: [Color.blue, Color.purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let secondary = LinearGradient(
            colors: [Color.purple, Color.pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let subtle = LinearGradient(
            colors: [Color.white.opacity(0.8), Color.white.opacity(0.4)],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static func card(isHovered: Bool) -> LinearGradient {
            LinearGradient(
                colors: [
                    Color(.textBackgroundColor).opacity(isHovered ? 0.9 : 0.6),
                    Color(.textBackgroundColor).opacity(isHovered ? 0.7 : 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: - Materials
    enum Material {
        static let sidebar = SwiftUI.Material.ultraThin
        static let content = SwiftUI.Material.regular
        static let card = SwiftUI.Material.thin
        static let popover = SwiftUI.Material.thick
    }

    // MARK: - Icon Sizes
    enum IconSize {
        /// 12pt - Tiny icons
        static let tiny: CGFloat = 12
        /// 16pt - Small icons in text
        static let small: CGFloat = 16
        /// 20pt - Default icon size
        static let medium: CGFloat = 20
        /// 24pt - Prominent icons
        static let large: CGFloat = 24
        /// 32pt - Feature icons
        static let xlarge: CGFloat = 32
        /// 48pt - Hero icons
        static let hero: CGFloat = 48
        /// 64pt - Empty state icons
        static let emptyState: CGFloat = 64
    }
    
    // MARK: - Z-Index
    enum ZIndex {
        static let background: Double = 0
        static let content: Double = 1
        static let overlay: Double = 10
        static let modal: Double = 50
        static let toast: Double = 100
    }
}

// MARK: - Semantic Colors
extension Color {
    enum Semantic {
        // Status Colors
        static let success = Color.green
        static let error = Color.red
        static let warning = Color.orange
        static let info = Color.blue
        
        // Background Colors
        static let primaryBackground = Color(.windowBackgroundColor)
        static let secondaryBackground = Color(.controlBackgroundColor)
        static let tertiaryBackground = Color(.textBackgroundColor)
        static let glassBackground = Color(.windowBackgroundColor).opacity(0.5)
        
        // Text Colors
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
        static let tertiaryText = Color(.tertiaryLabelColor)
        
        // Border Colors
        static let border = Color(.separatorColor)
        static let borderSubtle = Color(.separatorColor).opacity(0.2)
        static let borderStrong = Color(.separatorColor).opacity(0.5)
        
        // Accents
        static let accentPrimary = Color.accentColor
        static let accentSecondary = Color.purple
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    var isSelected: Bool = false
    var isHovered: Bool = false
    
    func body(content: Content) -> some View {
        content
            .padding(DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .fill(Color(.textBackgroundColor).opacity(0.8)) // More translucent
                    .shadow(
                        color: isHovered ? Color.black.opacity(0.1) : Color.black.opacity(0.05),
                        radius: isHovered ? 8 : 4,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .strokeBorder(
                        isSelected ? Color.accentColor : (isHovered ? Color.accentColor.opacity(0.3) : Color.Semantic.borderSubtle),
                        lineWidth: isSelected ? DesignTokens.BorderWidth.medium : DesignTokens.BorderWidth.thin
                    )
            )
            .scaleEffect(isHovered ? 1.005 : 1.0)
            .animation(DesignTokens.Animation.quick, value: isHovered)
    }
}

struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .fontWeight(.semibold)
    }
}

extension View {
    func cardStyle(isSelected: Bool = false, isHovered: Bool = false) -> some View {
        modifier(CardStyle(isSelected: isSelected, isHovered: isHovered))
    }
    
    func sectionHeader() -> some View {
        modifier(SectionHeaderStyle())
    }
}

// MARK: - Empty State View Component
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: DesignTokens.IconSize.emptyState, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.accentColor, .accentColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
    }
}
