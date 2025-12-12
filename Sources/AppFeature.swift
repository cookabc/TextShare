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

// MARK: - Settings Feature
@Reducer
struct SettingsFeature {
    struct State: Equatable {
        var fontFamily = FontFamily.system
        var fontSize = FontSize.medium
        var theme = Theme.light
        var padding: Double = 40
        var maxWidth: Double = 600
        var watermark: String?
    }

    enum FontFamily: String, CaseIterable, Equatable {
        case system = "System"
        case avenir = "Avenir"
        case helvetica = "Helvetica Neue"
        case menlo = "Menlo"
        case monaco = "Monaco"

        var displayName: String {
            switch self {
            case .system: return "System"
            case .avenir: return "Avenir"
            case .helvetica: return "Helvetica Neue"
            case .menlo: return "Menlo"
            case .monaco: return "Monaco"
            }
        }
    }

    enum FontSize: Int, CaseIterable, Equatable {
        case small = 16
        case medium = 20
        case large = 24
        case extraLarge = 32

        var displayName: String {
            switch self {
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
            case .extraLarge: return "Extra Large"
            }
        }
    }

    enum Theme: String, CaseIterable, Equatable {
        case light = "light"
        case dark = "dark"
        case gradient = "gradient"

        var displayName: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            case .gradient: return "Gradient"
            }
        }
    }

    enum Action {
        case updateFontFamily(FontFamily)
        case updateFontSize(FontSize)
        case updateTheme(Theme)
        case updatePadding(Double)
        case updateMaxWidth(Double)
        case updateWatermark(String?)
        case saveSettings
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateFontFamily(let fontFamily):
                state.fontFamily = fontFamily
                return .none

            case .updateFontSize(let fontSize):
                state.fontSize = fontSize
                return .none

            case .updateTheme(let theme):
                state.theme = theme
                return .none

            case .updatePadding(let padding):
                state.padding = padding
                return .none

            case .updateMaxWidth(let maxWidth):
                state.maxWidth = maxWidth
                return .none

            case .updateWatermark(let watermark):
                state.watermark = watermark
                return .none

            case .saveSettings:
                // This will be implemented in a later step
                return .none
            }
        }
    }
}