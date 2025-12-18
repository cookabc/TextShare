import SwiftUI
import ComposableArchitecture

// MARK: - Main Generate View
// Premium design with dashboard layout and glassmorphism elements

struct GenerateView: View {
    let store: StoreOf<GenerateFeature>
    
    @State private var toast: ToastData?

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HSplitView {
                // Left Panel: Input & Configuration
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.xl) {
                        // Header
                        HStack {
                            Text("Create")
                                .font(.system(size: 28, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        
                        // Text Input
                        textInputSection(viewStore: viewStore)
                        
                        // Configuration Grid
                        configurationSection(viewStore: viewStore)
                    }
                    .padding(DesignTokens.Spacing.lg)
                }
                .frame(minWidth: 350, maxWidth: 500)
                
                // Right Panel: Output Stage
                ZStack {
                    // Background
                    Color.Semantic.secondaryBackground
                        .ignoresSafeArea()
                    
                    // Dot Pattern or subtle gradient
                    GeometryReader { proxy in
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 600, height: 600)
                            .blur(radius: 100)
                            .position(x: proxy.size.width * 0.8, y: proxy.size.height * 0.2)
                        
                        Circle()
                            .fill(Color.purple.opacity(0.1))
                            .frame(width: 400, height: 400)
                            .blur(radius: 80)
                            .position(x: proxy.size.width * 0.2, y: proxy.size.height * 0.8)
                    }
                    
                    // Content
                    VStack(spacing: DesignTokens.Spacing.lg) {
                        Spacer()
                        generatedImageSection(viewStore: viewStore)
                        
                        actionButtonsSection(viewStore: viewStore)
                            .padding(.bottom, DesignTokens.Spacing.xl)
                        Spacer()
                    }
                    .padding(DesignTokens.Spacing.xl)
                }
                .frame(minWidth: 400, maxWidth: .infinity)
            }
            .background(DesignTokens.Material.content)
            .toast($toast)
            .onChange(of: viewStore.successMessage) { newValue in
                if let message = newValue {
                    toast = .success(message)
                    viewStore.send(.clearSuccessMessage)
                }
            }
            .onChange(of: viewStore.error) { newValue in
                if let errorMessage = newValue, !errorMessage.isEmpty {
                    toast = .error(errorMessage)
                }
            }
        }
    }
}

// MARK: - Text Input Section
private struct textInputSection: View {
    @ObservedObject var viewStore: ViewStoreOf<GenerateFeature>
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Label("Input Text", systemImage: "text.quote")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(viewStore.text.count) chars")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
            }
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: viewStore.binding(
                    get: { $0.text },
                    send: GenerateFeature.Action.updateText
                ))
                .font(.system(size: 16, weight: .regular, design: .default))
                .lineSpacing(4)
                .padding(12)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(minHeight: 120)
                
                if viewStore.text.isEmpty {
                    Text("Enter text to generate image...")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                        .padding(16)
                        .allowsHitTesting(false)
                }
            }
            .background(Color.Semantic.tertiaryBackground)
            .cornerRadius(DesignTokens.CornerRadius.md)
            .cardStyle(isSelected: isFocused, isHovered: false)
            .onTapGesture { isFocused = true }
        }
    }
}

// MARK: - Configuration Section
private struct configurationSection: View {
    @ObservedObject var viewStore: ViewStoreOf<GenerateFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label("Configuration", systemImage: "slider.horizontal.3")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                // Font Card
                configRow(
                    icon: "textformat",
                    title: "Font",
                    value: viewStore.currentConfig.fontFamily.displayName,
                    detail: viewStore.currentConfig.fontSize.displayName
                )
                
                // Theme Card
                configRow(
                    icon: "paintpalette",
                    title: "Theme",
                    value: viewStore.currentConfig.theme.displayName,
                    color: viewStore.currentConfig.theme.primaryColor
                )
            }
            
            Button(action: {
                // This would typically trigger navigation or a sheet
                // Parent view handles actual navigation via tab selection
            }) {
                Text("Customize Settings...")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .buttonStyle(.link)
            .padding(.leading, 4)
        }
    }
    
    // Helper view for config rows
    private func configRow(icon: String, title: String, value: String, detail: String? = nil, color: Color? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .frame(width: 32, height: 32)
                .background(Color.accentColor.opacity(0.1))
                .foregroundStyle(Color.accentColor)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            if let detail = detail {
                Text(detail)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.Semantic.tertiaryBackground)
                    .cornerRadius(4)
            }
            
            if let color = color {
                Circle()
                    .fill(color)
                    .frame(width: 16, height: 16)
                    .overlay(Circle().strokeBorder(Color.Semantic.border, lineWidth: 1))
            }
        }
        .padding(12)
        .background(Color.Semantic.tertiaryBackground.opacity(0.5))
        .cornerRadius(DesignTokens.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                .strokeBorder(Color.Semantic.borderSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Generated Image Section (The Hero)
private struct generatedImageSection: View {
    @ObservedObject var viewStore: ViewStoreOf<GenerateFeature>

    var body: some View {
        ZStack {
            // Shadow/Glow effect
            if viewStore.generatedImage != nil {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.accentColor.opacity(0.2))
                    .blur(radius: 20)
                    .offset(y: 10)
            }
            
            // Image Container
            VStack {
                if let imageData = viewStore.generatedImage,
                   let image = NSImage(data: imageData) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(.secondary.opacity(0.5))
                        
                        Text("Ready to Generate")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        Text("Type something on the left and hit Generate")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DesignTokens.Material.card)
                }
            }
            .frame(height: 350) // Fixed height for consistency
            .frame(maxWidth: 600)
            
            // Loading Overlay
            if viewStore.isGenerating {
                Color.black.opacity(0.2)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(height: 350)
                    .frame(maxWidth: 600)
                
                ProgressView()
                    .scaleEffect(1.5)
                    .controlSize(.large)
                    .tint(.white)
            }
        }
        .animation(DesignTokens.Animation.standard, value: viewStore.generatedImage)
        .animation(DesignTokens.Animation.standard, value: viewStore.isGenerating)
    }
}

// MARK: - Action Buttons Section
private struct actionButtonsSection: View {
    @ObservedObject var viewStore: ViewStoreOf<GenerateFeature>

    var body: some View {
        HStack(spacing: 16) {
            if viewStore.generatedImage != nil {
                Button(action: { viewStore.send(.clearContent) }) {
                    Label("Clear", systemImage: "trash")
                        .padding(.horizontal, 8)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(viewStore.isGenerating)
            }
            
            Spacer()
            
            if viewStore.generatedImage != nil {
                Group {
                    Button(action: { viewStore.send(.saveToHistory) }) {
                        Label("Save", systemImage: "clock.arrow.circlepath")
                    }
                    .disabled(viewStore.isSavingToHistory)
                    
                    Button(action: { viewStore.send(.exportImage) }) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .disabled(viewStore.isExporting)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            
            Button(action: {
                if viewStore.isGenerating {
                    viewStore.send(.cancelGeneration)
                } else {
                    viewStore.send(.generateImage)
                }
            }) {
                Label(
                    viewStore.isGenerating ? "Cancel" : "Generate",
                    systemImage: viewStore.isGenerating ? "xmark" : "sparkles"
                )
                .frame(minWidth: 100)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewStore.text.isEmpty && !viewStore.isGenerating)
            .keyboardShortcut(.defaultAction)
        }
        .frame(maxWidth: 600)
    }
}