import ComposableArchitecture
import Foundation

// MARK: - App Feature (Root)
@Reducer
struct AppFeature {
    struct State: Equatable {
        var sidebar = SidebarFeature.State()
        var mainContent = MainContentFeature.State()
    }

    enum Action {
        case sidebar(SidebarFeature.Action)
        case mainContent(MainContentFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.sidebar, action: /AppFeature.Action.sidebar) {
            SidebarFeature()
        }
        Scope(state: \.mainContent, action: /AppFeature.Action.mainContent) {
            MainContentFeature()
        }
    }
}

// MARK: - Sidebar Feature
@Reducer
struct SidebarFeature {
    struct State: Equatable {
        var selectedTab: Tab = .generate
    }

    enum Tab: String, CaseIterable, Equatable {
        case generate
        case history
        case settings

        var localizedName: String {
            switch self {
            case .generate: return "Generate"
            case .history: return "History"
            case .settings: return "Settings"
            }
        }

        var iconName: String {
            switch self {
            case .generate: return "photo"
            case .history: return "clock"
            case .settings: return "gear"
            }
        }
    }

    enum Action {
        case selectTab(Tab)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .selectTab(let tab):
                state.selectedTab = tab
                return .none
            }
        }
    }
}

// MARK: - Main Content Feature
@Reducer
struct MainContentFeature {
    struct State: Equatable {
        var selectedTab: SidebarFeature.State.Tab
        var generate = GenerateFeature.State()
        var history = HistoryFeature.State()
        var settings = SettingsFeature.State()
    }

    enum Action {
        case generate(GenerateFeature.Action)
        case history(HistoryFeature.Action)
        case settings(SettingsFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .generate, .history, .settings:
                // Actions are handled by child reducers
                return .none
            }
        }
        Scope(state: \.generate, action: /MainContentFeature.Action.generate) {
            GenerateFeature()
        }
        Scope(state: \.history, action: /MainContentFeature.Action.history) {
            HistoryFeature()
        }
        Scope(state: \.settings, action: /MainContentFeature.Action.settings) {
            SettingsFeature()
        }
    }
}

// MARK: - Generate Feature
@Reducer
struct GenerateFeature {
    struct State: Equatable {
        var text = ""
        var isGenerating = false
        var generatedImage: Data?
        var error: String?
    }

    enum Action {
        case updateText(String)
        case generateImage
        case imageGenerated(Data)
        case generateFailed(String)
        case clearError
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateText(let text):
                state.text = text
                state.error = nil
                return .none

            case .generateImage:
                guard !state.text.isEmpty else {
                    state.error = "Please enter some text first"
                    return .none
                }

                state.isGenerating = true
                state.error = nil

                // This will be implemented in a later step
                // For now, simulate image generation
                return .run { send in
                    // Simulate async image generation
                    try await Task.sleep(nanoseconds: 1_000_000_000)

                    // Mock image data (placeholder)
                    let mockImageData = Data()
                    await send(.imageGenerated(mockImageData))
                } catch: { error, send in
                    await send(.generateFailed(error.localizedDescription))
                }
                .cancellable(id: "image-generation")

            case .imageGenerated(let imageData):
                state.isGenerating = false
                state.generatedImage = imageData
                return .none

            case .generateFailed(let errorMessage):
                state.isGenerating = false
                state.error = errorMessage
                return .none

            case .clearError:
                state.error = nil
                return .none
            }
        }
    }
}

// MARK: - History Feature
@Reducer
struct HistoryFeature {
    struct State: Equatable {
        var items: [HistoryItem] = []
    }

    struct HistoryItem: Equatable, Identifiable {
        let id = UUID()
        let text: String
        let imageData: Data
        let createdAt: Date
    }

    enum Action {
        case addItem(HistoryItem)
        case removeItem(ID)
        case clearAll
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addItem(let item):
                state.items.insert(item, at: 0)
                return .none

            case .removeItem(let id):
                state.items.removeAll { $0.id == id }
                return .none

            case .clearAll:
                state.items.removeAll()
                return .none
            }
        }
    }
}

// MARK: - Settings Feature (Modern)
@Reducer
struct SettingsFeature {
    @Dependency(\.fontConfigManager) var fontConfigManager

    struct State: Equatable {
        var currentConfig = ExportConfiguration.default
        var recentConfigs: [ExportConfiguration] = []
        var favoriteConfigs: [ExportConfiguration] = []
        var isLoading = false
        var validationErrors: [ConfigurationError] = []
        var selectedPreset: ExportConfigurationPreset = .default

        // UI State
        var showAdvancedOptions = false
        var selectedFontFamily: ModernFontFamily = .system
        var selectedFontSize: ModernFontSize = .medium
        var selectedTheme: ModernTheme = .light
    }

    enum Action {
        case loadConfiguration
        case updateConfiguration(ExportConfiguration)
        case updateFontFamily(ModernFontFamily)
        case updateFontSize(ModernFontSize)
        case updateTheme(ModernTheme)
        case updatePadding(Double)
        case updateMaxWidth(Double)
        case updateLineHeight(Double)
        case updateWatermark(String?)
        case updateCornerRadius(Double)
        case updateBorderWidth(Double)
        case applyPreset(ExportConfigurationPreset)
        case addToFavorites(ExportConfiguration)
        case removeFromFavorites(ExportConfiguration)
        case validateConfiguration
        case resetToDefault
        case clearRecentConfigs
        case toggleAdvancedOptions
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadConfiguration:
                state.currentConfig = fontConfigManager.currentConfig
                state.recentConfigs = fontConfigManager.recentConfigs
                state.favoriteConfigs = fontConfigManager.favoriteConfigs
                state.selectedFontFamily = state.currentConfig.fontFamily
                state.selectedFontSize = state.currentConfig.fontSize
                state.selectedTheme = state.currentConfig.theme
                return .none

            case .updateConfiguration(let config):
                state.currentConfig = config
                state.selectedFontFamily = config.fontFamily
                state.selectedFontSize = config.fontSize
                state.selectedTheme = config.theme
                return .run { send in
                    await fontConfigManager.updateConfiguration(config)
                }

            case .updateFontFamily(let fontFamily):
                state.selectedFontFamily = fontFamily
                let newConfig = state.currentConfig.with(fontFamily: fontFamily)
                state.currentConfig = newConfig
                return .send(.updateConfiguration(newConfig))

            case .updateFontSize(let fontSize):
                state.selectedFontSize = fontSize
                let newConfig = state.currentConfig.with(fontSize: fontSize)
                state.currentConfig = newConfig
                return .send(.updateConfiguration(newConfig))

            case .updateTheme(let theme):
                state.selectedTheme = theme
                let newConfig = state.currentConfig.with(theme: theme)
                state.currentConfig = newConfig
                return .send(.updateConfiguration(newConfig))

            case .updatePadding(let padding):
                let newConfig = state.currentConfig.with(padding: padding)
                state.currentConfig = newConfig
                return .send(.updateConfiguration(newConfig))

            case .updateMaxWidth(let maxWidth):
                let newConfig = state.currentConfig.with(maxWidth: maxWidth)
                state.currentConfig = newConfig
                return .send(.updateConfiguration(newConfig))

            case .updateLineHeight(let lineHeight):
                var config = state.currentConfig
                config.lineHeight = lineHeight
                state.currentConfig = config
                return .send(.updateConfiguration(config))

            case .updateWatermark(let watermark):
                let newConfig = state.currentConfig.with(watermark: watermark)
                state.currentConfig = newConfig
                return .send(.updateConfiguration(newConfig))

            case .updateCornerRadius(let cornerRadius):
                var config = state.currentConfig
                config.cornerRadius = cornerRadius
                state.currentConfig = config
                return .send(.updateConfiguration(config))

            case .updateBorderWidth(let borderWidth):
                var config = state.currentConfig
                config.borderWidth = borderWidth
                state.currentConfig = config
                return .send(.updateConfiguration(config))

            case .applyPreset(let preset):
                state.selectedPreset = preset
                return .run { send in
                    await fontConfigManager.applyPreset(preset)
                    await send(.loadConfiguration)
                }

            case .addToFavorites(let config):
                return .run { send in
                    await fontConfigManager.addToFavorites(config)
                    await send(.loadConfiguration)
                }

            case .removeFromFavorites(let config):
                return .run { send in
                    await fontConfigManager.removeFromFavorites(config)
                    await send(.loadConfiguration)
                }

            case .validateConfiguration:
                return .run { send in
                    let errors = await fontConfigManager.validateConfiguration(state.currentConfig)
                    await send(.setValidationErrors(errors))
                }

            case .setValidationErrors(let errors):
                state.validationErrors = errors
                return .none

            case .resetToDefault:
                return .run { send in
                    await fontConfigManager.resetToDefault()
                    await send(.loadConfiguration)
                }

            case .clearRecentConfigs:
                return .run { send in
                    await fontConfigManager.clearRecentConfigs()
                    await send(.loadConfiguration)
                }

            case .toggleAdvancedOptions:
                state.showAdvancedOptions.toggle()
                return .none
            }
        }
    }
}