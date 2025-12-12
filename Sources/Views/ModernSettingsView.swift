import SwiftUI
import ComposableArchitecture

// MARK: - Modern Settings View
// Modern SwiftUI features: component composition, async/await, animation

struct ModernSettingsView: View {
    let store: StoreOf<SettingsFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    // Presets Section
                    Section("Presets") {
                        presetsGrid(store: store)
                    }

                    // Basic Settings Section
                    Section("Basic Settings") {
                        basicSettingsControls(store: store)
                    }

                    // Advanced Settings Section
                    if viewStore.showAdvancedOptions {
                        Section("Advanced Settings") {
                            advancedSettingsControls(store: store)
                        }
                    }

                    // Actions Section
                    Section("Actions") {
                        actionsView(store: store)
                    }

                    // Validation Errors
                    if !viewStore.validationErrors.isEmpty {
                        Section("Configuration Errors") {
                            validationErrorsView(errors: viewStore.validationErrors)
                        }
                    }
                }
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button("Advanced") {
                            viewStore.send(.toggleAdvancedOptions)
                        }
                        .foregroundColor(viewStore.showAdvancedOptions ? .accentColor : .secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Presets Grid
private struct presetsGrid: View {
    let store: StoreOf<SettingsFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(ExportConfigurationPreset.allCases, id: \.self) { preset in
                    presetCard(preset: preset, isSelected: viewStore.selectedPreset == preset, store: store)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

private struct presetCard: View {
    let preset: ExportConfigurationPreset
    let isSelected: Bool
    let store: StoreOf<SettingsFeature.State>

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: preset.iconName)
                .font(.title2)
                .foregroundColor(color(for: preset))

            Text(preset.displayName)
                .font(.headline)
                .foregroundColor(.primary)

            Text(preset.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color(for: preset))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(color(for: preset), lineWidth: isSelected ? 2 : 1)
                )
        )
        .onTapGesture {
            store.send(.applyPreset(preset))
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private func color(for preset: ExportConfigurationPreset) -> Color {
        switch preset {
        case .default: return .blue
        case .codeFocused: return .orange
        case .presentation: return .purple
        case .minimal: return .gray
        }
    }
}

extension ExportConfigurationPreset {
    var iconName: String {
        switch self {
        case .default: return "doc.text"
        case .codeFocused: return "terminal"
        case .presentation: return "person.3"
        case .minimal: return "doc.plaintext"
        }
    }
}

// MARK: - Basic Settings Controls
private struct basicSettingsControls: View {
    let store: StoreOf<SettingsFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            // Font Family
            Picker("Font Family", selection: Binding(
                get: { viewStore.selectedFontFamily },
                set: { viewStore.send(.updateFontFamily($0)) }
            )) {
                ForEach(ModernFontFamily.allCases, id: \.self) { family in
                    HStack {
                        if family.isCodeFont {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .foregroundColor(.accentColor)
                                .font(.caption)
                        }
                        Text(family.displayName)
                            .font(family.isCodeFont ? .monospaced(.caption()) : .body)
                    }
                    .tag(family)
                }
            }

            // Font Size
            Picker("Font Size", selection: Binding(
                get: { viewStore.selectedFontSize },
                set: { viewStore.send(.updateFontSize($0)) }
            )) {
                ForEach(ModernFontSize.allCases, id: \.self) { size in
                    HStack {
                        Text(size.displayName)
                        Spacer()
                        Text("\(size.pointSize)pt")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .tag(size)
                }
            }

            // Theme
            Picker("Theme", selection: Binding(
                get: { viewStore.selectedTheme },
                set: { viewStore.send(.updateTheme($0)) }
            )) {
                ForEach(ModernTheme.allCases, id: \.self) { theme in
                    themeRow(theme)
                        .tag(theme)
                }
            }

            // Preview
            themePreviewRow(store: store)
        }
    }
}

private struct themeRow: View {
    let theme: ModernTheme

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(theme.primaryColor)
                .frame(width: 20, height: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(theme.accentColor, lineWidth: 2)
                )

            Text(theme.displayName)
                .foregroundColor(.primary)

            Spacer()

            Text(theme.colorScheme == .dark ? "🌙" : "☀️")
                .font(.title2)
        }
    }
}

private struct themePreviewRow: View {
    let store: StoreOf<SettingsFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Text("Aa Bb Cc")
                        .font(viewStore.currentConfig.fontFamily.nativeFont)
                        .foregroundColor(viewStore.currentConfig.theme.textColor)

                    Text("123 456 789")
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                RoundedRectangle(cornerRadius: 4)
                    .fill(viewStore.currentConfig.theme.accentColor.opacity(0.2))
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(viewStore.currentConfig.theme.primaryColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(viewStore.currentConfig.theme.accentColor, lineWidth: 1)
            )
        }
        .frame(height: 60)
        .onTapGesture {
            // Toggle theme preview
        }
    }
}

// MARK: - Advanced Settings Controls
private struct advancedSettingsControls: View {
    let store: StoreOf<SettingsFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            // Layout Controls
            Group {
                HStack {
                    Text("Padding:")
                    Spacer()
                    Text("\(Int(viewStore.currentConfig.padding))px")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                Slider(value: Binding(
                    get: { viewStore.currentConfig.padding },
                    set: { viewStore.send(.updatePadding($0)) }
                ), in: 10...100)
            }

            Group {
                HStack {
                    Text("Max Width:")
                    Spacer()
                    Text("\(Int(viewStore.currentConfig.maxWidth))px")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                Slider(value: Binding(
                    get: { viewStore.currentConfig.maxWidth },
                    set: { viewStore.send(.updateMaxWidth($0)) }
                ), in: 200...1200)
            }

            Group {
                HStack {
                    Text("Line Height:")
                    Spacer()
                    Text(String(format: "%.1f", viewStore.currentConfig.lineHeight))
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                Slider(value: Binding(
                    get: { viewStore.currentConfig.lineHeight },
                    set: { viewStore.send(.updateLineHeight($0)) }
                ), in: 0.5...3.0)
                .step(0.1)
            }

            Group {
                HStack {
                    Text("Corner Radius:")
                    Spacer()
                    Text("\(Int(viewStore.currentConfig.cornerRadius))px")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                Slider(value: Binding(
                    get: { viewStore.currentConfig.cornerRadius },
                    set: { viewStore.send(.updateCornerRadius($0)) }
                ), in: 0...30)
            }

            // Watermark
            TextField("Watermark (optional)", text: Binding(
                get: { viewStore.currentConfig.watermark ?? "" },
                set: { viewStore.send(.updateWatermark($0.isEmpty ? nil : $0)) }
            ))
                .textFieldStyle(.roundedBorder)
        }
    }
}

// MARK: - Actions View
private struct actionsView: View {
    let store: StoreOf<SettingsFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 12) {
                HStack {
                    Button("Reset to Default") {
                        viewStore.send(.resetToDefault)
                    }
                    .buttonStyle(.bordered)

                    Button("Validate") {
                        viewStore.send(.validateConfiguration)
                    }
                    .buttonStyle(.borderedProminent)
                }

                HStack {
                    Button("Clear Recent") {
                        viewStore.send(.clearRecentConfigs)
                    }
                    .buttonStyle(.bordered)

                    if !viewStore.favoriteConfigs.contains(viewStore.currentConfig) {
                        Button("Add to Favorites") {
                            viewStore.send(.addToFavorites(viewStore.currentConfig))
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Remove from Favorites") {
                            viewStore.send(.removeFromFavorites(viewStore.currentConfig))
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}

// MARK: - Validation Errors View
private struct validationErrorsView: View {
    let errors: [ConfigurationError]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(errors, id: \.self) { error in
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)

                    Text(error.errorDescription ?? "Unknown error")
                        .font(.callout)
                        .foregroundColor(.red)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)
            }
        }
    }
}

// MARK: - Modern Settings View Extension
extension ModernSettingsView {
    private func fontConfigurationView(_ config: ExportConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Configuration Preview")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Font: \(config.fontFamily.displayName)")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Size: \(config.fontSize.displayName)")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Theme: \(config.theme.displayName)")
                .font(.caption)
                .foregroundColor(.secondary)

            if let watermark = config.watermark {
                Text("Watermark: \(watermark)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color(.separatorColor), lineWidth: 1)
                )
        )
    }
}