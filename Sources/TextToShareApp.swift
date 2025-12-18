import SwiftUI
import ComposableArchitecture

@main
struct TextToShareApp: App {
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    } withDependencies: { _ in
        // Dependencies are configured through the dependency system
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
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(store, observe: { $0.mainContent }) { viewStore in
            NavigationSplitView {
                // Sidebar
                SidebarView(store: store.scope(state: \.sidebar, action: AppFeature.Action.sidebar))
                    .navigationTitle("TextToShare")
                    .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            } detail: {
                // Main Content
                MainContentView(store: store.scope(state: \.mainContent, action: AppFeature.Action.mainContent))
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        viewStore.send(.mainContent(.generate(.generateImage)))
                    }) {
                        Image(systemName: "photo")
                        Text("Generate")
                    }
                    .keyboardShortcut("g", modifiers: [.command, .shift])
                    .disabled(viewStore.generate.isGenerating)

                    if viewStore.generate.isGenerating {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
        }
    }
}

struct SidebarView: View {
    let store: StoreOf<SidebarFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Button(action: {
                    viewStore.send(.selectTab(.generate))
                }) {
                    Label("Generate", systemImage: "photo")
                }
                .tag(SidebarFeature.Tab.generate)

                Button(action: {
                    viewStore.send(.selectTab(.history))
                }) {
                    Label("History", systemImage: "clock")
                }
                .tag(SidebarFeature.Tab.history)

                Button(action: {
                    viewStore.send(.selectTab(.settings))
                }) {
                    Label("Settings", systemImage: "gear")
                }
                .tag(SidebarFeature.Tab.settings)
            }
        }
    }
}

struct MainContentView: View {
    let store: StoreOf<MainContentFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            switch viewStore.selectedTab {
            case .generate:
                GenerateContentView(store: store.scope(state: \.generate, action: \.generate))
            case .history:
                HistoryContentView(store: store.scope(state: \.history, action: \.history))
            case .settings:
                SettingsContentView(store: store.scope(state: \.settings, action: \.settings))
            }
        }
        .onAppear {
            // Load history when history tab is first accessed
        }
    }
}

// Modern SwiftUI Views
typealias GenerateContentView = GenerateView
typealias HistoryContentView = HistoryView
typealias SettingsContentView = ModernSettingsView