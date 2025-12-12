import SwiftUI
import ComposableArchitecture

// MARK: - Main Generate View
// Modern SwiftUI features: async/await, state management, animations

struct GenerateView: View {
    let store: StoreOf<GenerateFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 24) {
                // Text Input Section
                textInputSection(viewStore: viewStore)

                // Configuration Preview
                configurationPreviewSection(viewStore: viewStore)

                // Generated Image Display
                generatedImageSection(viewStore: viewStore)

                // Action Buttons
                actionButtonsSection(viewStore: viewStore)
            }
            .padding(24)
            .background(Color(.controlBackgroundColor))
            .frame(minWidth: 600, minHeight: 500)
        }
    }
}

// MARK: - Text Input Section
private struct textInputSection: View {
    @ObservedObject var viewStore: ViewStoreOf<GenerateFeature.State>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("输入文本")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(viewStore.text.count) 字符")
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
                        .foregroundColor(.tertiary)
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
    @ObservedObject var viewStore: ViewStoreOf<GenerateFeature.State>

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
                            .font(viewStore.currentConfig.fontFamily.isCodeFont ? .monospaced(.body) : .body)
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
    @ObservedObject var viewStore: ViewStoreOf<GenerateFeature.State>

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
                            .foregroundColor(.tertiary)

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
    @ObservedObject var viewStore: ViewStoreOf<GenerateFeature.State>

    var body: some View {
        HStack(spacing: 16) {
            // Generate Button
            Button(action: {
                viewStore.send(.generateImage)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: viewStore.isGenerating ? "stop.fill" : "photo")
                    Text(viewStore.isGenerating ? "取消生成" : "生成图片")
                }
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut("g", modifiers: .command.shift)
            .disabled(viewStore.text.isEmpty || (viewStore.isGenerating && viewStore.generatedImage == nil))

            // Clear Button
            Button(action: {
                viewStore.send(.clearContent)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                    Text("清空")
                }
            }
            .buttonStyle(.bordered)
            .keyboardShortcut("k", modifiers: .command)
            .disabled(viewStore.text.isEmpty && viewStore.generatedImage == nil)

            Spacer()

            // Export Button (only show when image exists)
            if viewStore.generatedImage != nil {
                Button(action: {
                    viewStore.send(.exportImage)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("导出")
                    }
                }
                .buttonStyle(.bordered)
                .keyboardShortcut("e", modifiers: .command)
            }
        }

        // Error Display
        if let error = viewStore.error {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text(error)
                    .foregroundColor(.red)
                Button("清除") {
                    viewStore.send(.clearError)
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red.opacity(0.1))
            )
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
#Preview {
    GenerateView(
        store: Store(initialState: GenerateFeature.State()) {
            GenerateFeature()
        }
    )
}