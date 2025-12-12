import SwiftUI
import ComposableArchitecture

@main
struct TextToShareApp: App {
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    } dependency: {
        FontConfigManagerKey.liveValue
        FontServiceKey.liveValue
        FontPreviewGeneratorKey.liveValue
        FontMetricsCalculatorKey.liveValue
    }
}

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Preferences…") {
                    NSApp.sendAction(Selector(("showPreferences:")), to: nil, from: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        .defaultSize(width: 800, height: 600)
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationSplitView {
                // Sidebar
                SidebarView(store: store.scope(state: \.sidebar, action: AppFeature.Action.sidebar))
                    .navigationTitle("TextToShare")
                    .navigationSplitViewColumnWidth(min: 200, ideal: 250)

                // Main Content
                MainContentView(store: store.scope(state: \.mainContent, action: AppFeature.Action.mainContent))
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        viewStore.send(.mainContent(.generateImage))
                    }) {
                        Image(systemName: "photo")
                        Text("Generate")
                    }
                    .keyboardShortcut("g", modifiers: .command.shift)
                    .disabled(viewStore.mainContent.isGenerating)

                    if viewStore.mainContent.isGenerating {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
        }
    }
}

struct SidebarView: View {
    let store: StoreOf<SidebarFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            List(selection: $viewStore.binding(\.$selectedTab, send: SidebarFeature.Action.selectTab)) {
                Label("Generate", systemImage: "photo")
                    .tag(SidebarFeature.State.Tab.generate)

                Label("History", systemImage: "clock")
                    .tag(SidebarFeature.State.Tab.history)

                Label("Settings", systemImage: "gear")
                    .tag(SidebarFeature.State.Tab.settings)
            }
        }
    }
}

struct MainContentView: View {
    let store: StoreOf<MainContentFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.selectedTab {
            case .generate:
                GenerateContentView(store: store.scope(state: \.generate, action: MainContentFeature.Action.generate))
            case .history:
                HistoryContentView(store: store.scope(state: \.history, action: MainContentFeature.Action.history))
            case .settings:
                SettingsContentView(store: store.scope(state: \.settings, action: MainContentFeature.Action.settings))
            }
        }
    }
}

// Modern SwiftUI Views
typealias GenerateContentView = GenerateView
typealias HistoryContentView = HistoryView
typealias SettingsContentView = ModernSettingsView