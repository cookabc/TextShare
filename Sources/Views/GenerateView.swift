import SwiftUI
import ComposableArchitecture

// MARK: - Main Generate View
// Modern SwiftUI features: async/await, state management, animations

struct GenerateView: View {
    let store: StoreOf<GenerateFeature>
    
    @State private var toast: ToastData?

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: DesignTokens.Spacing.lg) {
                // Text Input Section
                textInputSection(viewStore: viewStore)

                // Configuration Preview
                configurationPreviewSection(viewStore: viewStore)

                // Generated Image Display
                generatedImageSection(viewStore: viewStore)

                // Action Buttons
                actionButtonsSection(viewStore: viewStore)
            }
            .padding(DesignTokens.Spacing.lg)
            .background(Color(.controlBackgroundColor))
            .frame(minWidth: 600, minHeight: 500)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(NSLocalizedString("text_input_title", comment: ""))
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Text(String(format: NSLocalizedString("character_count", comment: ""), viewStore.text.count))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color(.separatorColor), lineWidth: 1)
                    )

                if viewStore.text.isEmpty {
                    Text("请输入要转换成图片的文本...")
                        .foregroundColor(.secondary.opacity(0.6))
                        .padding(16)
                        .allowsHitTesting(false)
                }

                TextEditor(text: viewStore.binding(
                    get: { $0.text },
                    send: GenerateFeature.Action.updateText
                ))
                .padding(12)
                .background(Color.clear)
                .font(.system(size: 16))
                .scrollContentBackground(.hidden)
            }
            .frame(height: 120)
        }
    }
}

// MARK: - Configuration Preview Section
private struct configurationPreviewSection: View {
    @ObservedObject var viewStore: ViewStoreOf<GenerateFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("当前配置")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 16) {
                // Font Info
                VStack(alignment: .leading, spacing: 4) {
                    Text("字体")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        Image(systemName: "textformat")
                            .foregroundColor(.accentColor)
                        Text(viewStore.currentConfig.fontFamily.displayName)
                            .font(viewStore.currentConfig.fontFamily.isCodeFont ? .system(.body, design: .monospaced) : .body)
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(viewStore.currentConfig.fontSize.displayName)
                            .font(.body)
                    }
                }

                Divider()
                    .frame(height: 40)

                // Theme Info
                VStack(alignment: .leading, spacing: 4) {
                    Text("主题")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(viewStore.currentConfig.theme.primaryColor)
                            .frame(width: 16, height: 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(viewStore.currentConfig.theme.accentColor, lineWidth: 1)
                            )
                        Text(viewStore.currentConfig.theme.displayName)
                            .font(.body)
                    }
                }

                Spacer()

                // Settings Button
                Button("设置...") {
                    // Navigate to settings - this will be handled by parent
                }
                .buttonStyle(.bordered)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color(.separatorColor), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Generated Image Section
private struct generatedImageSection: View {
    @ObservedObject var viewStore: ViewStoreOf<GenerateFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("生成的图片")
                    .font(.title2)
                    .fontWeight(.semibold)

                if viewStore.isGenerating {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("生成中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        viewStore.generatedImage != nil ? Color.accentColor : Color(.separatorColor),
                        lineWidth: viewStore.generatedImage != nil ? 2 : 1
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.controlBackgroundColor))
                    )
                    .frame(minHeight: 200)

                if let imageData = viewStore.generatedImage,
                   let image = NSImage(data: imageData) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(radius: 4)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary.opacity(0.6))

                        Text("输入文本后点击生成按钮")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .allowsHitTesting(false)
                }

                if viewStore.isGenerating {
                    Color.black.opacity(0.1)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
            }
            .clipped()
        }
    }
}

// MARK: - Action Buttons Section
private struct actionButtonsSection: View {
    @ObservedObject var viewStore: ViewStoreOf<GenerateFeature>

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack(spacing: DesignTokens.Spacing.md) {
                // Generate/Cancel Button
                if viewStore.isGenerating {
                    Button(action: {
                        viewStore.send(.cancelGeneration)
                    }) {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            Image(systemName: "stop.fill")
                            Text(NSLocalizedString("generating", comment: ""))
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                } else {
                    Button(action: {
                        viewStore.send(.generateImage)
                    }) {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            Image(systemName: "photo")
                            Text(NSLocalizedString("generate", comment: ""))
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut("g", modifiers: [.command, .shift])
                    .disabled(viewStore.text.isEmpty)
                }

                // Clear Button
                Button(action: {
                    viewStore.send(.clearContent)
                }) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: "trash")
                        Text(NSLocalizedString("clear", comment: ""))
                    }
                }
                .buttonStyle(.bordered)
                .keyboardShortcut("k", modifiers: .command)
                .disabled(viewStore.text.isEmpty && viewStore.generatedImage == nil)

                Spacer()

                // Save to History Button (only show when image exists)
                if viewStore.generatedImage != nil && !viewStore.isSavingToHistory {
                    Button(action: {
                        viewStore.send(.saveToHistory)
                    }) {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            Image(systemName: "clock.arrow.circlepath")
                            Text(NSLocalizedString("save_to_history", comment: ""))
                        }
                    }
                    .buttonStyle(.bordered)
                    .keyboardShortcut("s", modifiers: .command)
                }

                // Export Button (only show when image exists)
                if viewStore.generatedImage != nil && !viewStore.isExporting {
                    Button(action: {
                        viewStore.send(.exportImage)
                    }) {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            Image(systemName: "square.and.arrow.up")
                            Text(NSLocalizedString("export", comment: ""))
                        }
                    }
                    .buttonStyle(.bordered)
                    .keyboardShortcut("e", modifiers: .command)
                }
                
                // Show loading indicator when exporting
                if viewStore.isExporting || viewStore.isSavingToHistory {
                    ProgressView()
                        .controlSize(.small)
                }
            }
        }
    }
}

// MARK: - Generate View Extensions
extension GenerateView {
    // Helper method to show configuration settings
    private func showSettings() {
        // This would typically navigate to the settings tab
        // Implementation depends on the parent navigation structure
    }
}

// MARK: - Preview
// MARK: - Preview
// #Preview temporarily removed due to macro compilation issues