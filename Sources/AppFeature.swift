import ComposableArchitecture
import Foundation
import AppKit

// MARK: - App Feature (Root)
@Reducer
struct AppFeature {
    struct State: Equatable {
        var sidebar = SidebarFeature.State()
        var mainContent = MainContentFeature.State(selectedTab: .generate)
    }

    enum Action {
        case sidebar(SidebarFeature.Action)
        case mainContent(MainContentFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.sidebar, action: \.sidebar) {
            SidebarFeature()
        }
        Scope(state: \.mainContent, action: \.mainContent) {
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
        var selectedTab: SidebarFeature.Tab
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
        Scope(state: \.generate, action: \.generate) {
            GenerateFeature()
        }
        Scope(state: \.history, action: \.history) {
            HistoryFeature()
        }
        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }
    }
}

// MARK: - Generate Feature
@Reducer
struct GenerateFeature {
    @Dependency(ImageGeneratorKey.self) var imageGenerator
    @Dependency(ImageFileManagerKey.self) var imageFileManager

    struct State: Equatable {
        var text = ""
        var isGenerating = false
        var isExporting = false
        var isSavingToHistory = false
        var generatedImage: Data?
        var error: String?
        var successMessage: String?
        var currentConfig = ExportConfiguration.default
    }

    enum Action {
        case updateText(String)
        case generateImage
        case cancelGeneration
        case imageGenerated(Data)
        case generateFailed(String)
        case clearError
        case clearSuccessMessage
        case clearContent
        case exportImage
        case exportImageCompleted(URL?)
        case exportImageFailed(String)
        case updateConfiguration(ExportConfiguration)
        case saveToHistory
        case saveToHistoryCompleted
        case saveToHistoryFailed(String)
    }
    
    private enum CancelID {
        case imageGeneration
        case export
        case saveHistory
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
                    state.error = NSLocalizedString("msg_enter_text", comment: "")
                    return .none
                }

                state.isGenerating = true
                state.error = nil
                let text = state.text
                let config = state.currentConfig

                return .run { send in
                    do {
                        let imageData = try await imageGenerator.generateImage(
                            from: text,
                            with: config
                        )
                        await send(.imageGenerated(imageData))
                    } catch {
                        await send(.generateFailed(error.localizedDescription))
                    }
                }
                .cancellable(id: CancelID.imageGeneration, cancelInFlight: true)
                
            case .cancelGeneration:
                state.isGenerating = false
                return .cancel(id: CancelID.imageGeneration)

            case .imageGenerated(let imageData):
                state.isGenerating = false
                state.generatedImage = imageData
                state.successMessage = NSLocalizedString("msg_gen_success", comment: "")
                return .none

            case .generateFailed(let errorMessage):
                state.isGenerating = false
                state.error = errorMessage
                return .none

            case .clearError:
                state.error = nil
                return .none
                
            case .clearSuccessMessage:
                state.successMessage = nil
                return .none

            case .clearContent:
                state.text = ""
                state.generatedImage = nil
                state.error = nil
                state.successMessage = nil
                return .none

            case .exportImage:
                guard let imageData = state.generatedImage else {
                    state.error = NSLocalizedString("msg_no_image_export", comment: "")
                    return .none
                }
                
                state.isExporting = true
                state.error = nil

                return .run { send in
                    do {
                        let url = try await imageFileManager.exportWithSaveDialog(imageData)
                        await send(.exportImageCompleted(url))
                    } catch {
                        await send(.exportImageFailed(error.localizedDescription))
                    }
                }
                .cancellable(id: CancelID.export)
                
            case .exportImageCompleted(let url):
                state.isExporting = false
                if url != nil {
                    state.successMessage = NSLocalizedString("msg_export_success", comment: "")
                }
                return .none
                
            case .exportImageFailed(let errorMessage):
                state.isExporting = false
                state.error = String(format: NSLocalizedString("msg_export_fail", comment: ""), errorMessage)
                return .none

            case .updateConfiguration(let config):
                state.currentConfig = config
                return .none

            case .saveToHistory:
                guard let imageData = state.generatedImage else {
                    state.error = NSLocalizedString("msg_no_image_save", comment: "")
                    return .none
                }
                
                state.isSavingToHistory = true

                let historyItem = HistoryItemData(
                    text: state.text,
                    imageData: imageData,
                    configuration: state.currentConfig
                )

                return .run { send in
                    do {
                        try await imageFileManager.saveHistoryItem(historyItem)
                        await send(.saveToHistoryCompleted)
                    } catch {
                        await send(.saveToHistoryFailed(error.localizedDescription))
                    }
                }
                .cancellable(id: CancelID.saveHistory)
                
            case .saveToHistoryCompleted:
                state.isSavingToHistory = false
                state.successMessage = NSLocalizedString("msg_save_success", comment: "")
                return .none
                
            case .saveToHistoryFailed(let errorMessage):
                state.isSavingToHistory = false
                state.error = String(format: NSLocalizedString("msg_save_fail", comment: ""), errorMessage)
                return .none
            }
        }
    }
}


// MARK: - Helper Functions
private func exportImage(_ imageData: Data) async {
    let imageFileManager = ImageFileManager.shared

    do {
        _ = try await imageFileManager.exportWithSaveDialog(imageData)
    } catch {
        print("Failed to export image: \(error)")
    }
}

// Legacy helper function (kept for compatibility)
private func createTestImageData(for text: String) async -> Data {
    await Task.detached {
        let size = NSSize(width: 400, height: 200)
        let image = NSImage(size: size)

        image.lockFocus()
        defer { image.unlockFocus() }

        // Create a simple background
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()

        // Draw text
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 16),
            .foregroundColor: NSColor.black
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textRect = NSRect(x: 20, y: size.height/2 - 10, width: size.width - 40, height: 20)
        attributedString.draw(in: textRect)

        // Convert to data
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            return Data()
        }

        return pngData
    }.value
}

// MARK: - History Feature
@Reducer
struct HistoryFeature {
    @Dependency(ImageFileManagerKey.self) var imageFileManager

    struct State: Equatable {
        var items: [HistoryItemData] = []
        var currentFilter: Filter = .all
        var isLoading = false
        var error: String?
    }

    enum Filter: String, CaseIterable, Equatable {
        case all = "all"
        case recent = "recent"
        case favorites = "favorites"

        var localizedName: String {
            switch self {
            case .all: return "全部"
            case .recent: return "最近"
            case .favorites: return "收藏"
            }
        }

        var iconName: String {
            switch self {
            case .all: return "list.bullet"
            case .recent: return "clock"
            case .favorites: return "heart"
            }
        }
    }

    struct HistoryItem: Equatable, Identifiable {
        let id: UUID
        let text: String
        let imageData: Data
        let createdAt: Date
        let configuration: ExportConfiguration
        let isFavorite: Bool

        init(from data: HistoryItemData) {
            self.id = data.id
            self.text = data.text
            self.imageData = data.imageData
            self.createdAt = data.createdAt
            self.configuration = data.configuration
            self.isFavorite = data.isFavorite
        }

        var toHistoryItemData: HistoryItemData {
            return HistoryItemData(
                id: id,
                text: text,
                imageData: imageData,
                configuration: configuration,
                isFavorite: isFavorite,
                createdAt: createdAt
            )
        }
    }

    enum Action {
        case loadHistory
        case addItem(HistoryItemData)
        case removeItem(UUID)
        case clearAll
        case setFilter(Filter)
        case regenerateFromItem(HistoryItemData)
        case toggleFavorite(UUID)
        case historyLoaded([HistoryItemData])
        case historyLoadFailed(String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadHistory:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    do {
                        let historyData = try await imageFileManager.loadHistory()
                        await send(.historyLoaded(historyData.items))
                    } catch {
                        await send(.historyLoadFailed(error.localizedDescription))
                    }
                }

            case .historyLoaded(let historyItems):
                state.isLoading = false
                state.items = historyItems
                return .none

            case .historyLoadFailed(let errorMessage):
                state.isLoading = false
                state.error = errorMessage
                return .none

            case .addItem(let item):
                state.items.insert(item, at: 0)
                return .none

            case .removeItem(let id):
                state.items.removeAll { $0.id == id }
                return .run { send in
                    do {
                        try await imageFileManager.removeFromHistory(id: id)
                    } catch {
                        print("Failed to remove from history: \(error)")
                    }
                }

            case .clearAll:
                state.items.removeAll()
                return .run { send in
                    do {
                        try await imageFileManager.clearHistory()
                    } catch {
                        print("Failed to clear history: \(error)")
                    }
                }

            case .setFilter(let filter):
                state.currentFilter = filter
                return .none

            case .regenerateFromItem(let item):
                // This will be handled by parent feature
                return .none

            case .toggleFavorite(let id):
                // In a real implementation, we'd toggle the favorite status
                // For now, just log the action
                return .none
            }
        }
    }
}

// MARK: - History Feature Extensions
extension HistoryFeature.State {
    func filteredItems(for filter: HistoryFeature.Filter) -> [HistoryItemData] {
        switch filter {
        case .all:
            return items
        case .recent:
            let oneDayAgo = Date().addingTimeInterval(-24 * 60 * 60)
            return items.filter { $0.createdAt >= oneDayAgo }
        case .favorites:
            return items.filter { $0.isFavorite }
        }
    }
}

// MARK: - Settings Feature (Modern)
@Reducer
struct SettingsFeature {
    @Dependency(FontConfigManagerKey.self) var fontConfigManager

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
        case setValidationErrors([ConfigurationError])
        case resetToDefault
        case clearRecentConfigs
        case toggleAdvancedOptions
        case configurationLoaded(currentConfig: ExportConfiguration, recentConfigs: [ExportConfiguration], favoriteConfigs: [ExportConfiguration])
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadConfiguration:
                return .run { send in
                    let (currentConfig, recentConfigs, favoriteConfigs) = await MainActor.run {
                        (
                            fontConfigManager.currentConfig,
                            fontConfigManager.recentConfigs,
                            fontConfigManager.favoriteConfigs
                        )
                    }
                    await send(.configurationLoaded(
                        currentConfig: currentConfig,
                        recentConfigs: recentConfigs,
                        favoriteConfigs: favoriteConfigs
                    ))
                }

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
                let config = state.currentConfig
                return .run { send in
                    let errors = await fontConfigManager.validateConfiguration(config)
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

            case .configurationLoaded(let currentConfig, let recentConfigs, let favoriteConfigs):
                state.currentConfig = currentConfig
                state.recentConfigs = recentConfigs
                state.favoriteConfigs = favoriteConfigs
                state.selectedFontFamily = currentConfig.fontFamily
                state.selectedFontSize = currentConfig.fontSize
                state.selectedTheme = currentConfig.theme
                return .none
            }
        }
    }
}