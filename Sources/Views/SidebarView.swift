import SwiftUI
import ComposableArchitecture

struct SidebarView: View {
    let store: StoreOf<SidebarFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                // Determine padding based on window control position
                // MacOS typically puts traffic lights at top left, needing ~40-50pt padding
                Color.clear.frame(height: 50)
                
                VStack(spacing: DesignTokens.Spacing.xs) {
                    SidebarItem(
                        title: SidebarFeature.Tab.generate.localizedName,
                        icon: SidebarFeature.Tab.generate.iconName,
                        isSelected: viewStore.selectedTab == .generate,
                        action: { viewStore.send(.selectTab(.generate)) }
                    )
                    
                    SidebarItem(
                        title: SidebarFeature.Tab.history.localizedName,
                        icon: SidebarFeature.Tab.history.iconName,
                        isSelected: viewStore.selectedTab == .history,
                        action: { viewStore.send(.selectTab(.history)) }
                    )
                    
                    Spacer()
                        .frame(height: DesignTokens.Spacing.lg)
                    
                    SidebarItem(
                        title: SidebarFeature.Tab.settings.localizedName,
                        icon: SidebarFeature.Tab.settings.iconName,
                        isSelected: viewStore.selectedTab == .settings,
                        action: { viewStore.send(.selectTab(.settings)) }
                    )
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                
                Spacer()
            }
            .background(DesignTokens.Material.sidebar) // Use the new material token
            .edgesIgnoringSafeArea(.top)
        }
    }
}

private struct SidebarItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.compact) {
                Image(systemName: icon)
                    .font(.system(size: DesignTokens.IconSize.medium))
                    .frame(width: 24) // Fixed width for alignment
                
                Text(title)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 6, height: 6)
                        .shadow(color: Color.accentColor.opacity(0.5), radius: 4)
                }
            }
            .foregroundColor(isSelected ? .white : (isHovered ? .primary : .secondary))
            .padding(.vertical, DesignTokens.Spacing.compact)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                        .fill(DesignTokens.Gradient.secondary)
                        .opacity(0.8)
                } else if isHovered {
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                        .fill(Color.primary.opacity(0.05))
                }
            }
        )
        .onHover { isHovered in
            withAnimation(DesignTokens.Animation.quick) {
                self.isHovered = isHovered
            }
        }
        .scaleEffect(isHovered && !isSelected ? 1.02 : 1.0)
        .animation(DesignTokens.Animation.quick, value: isHovered)
    }
}
