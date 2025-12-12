import SwiftUI
import ComposableArchitecture

@main
struct TextToShareApp: App {
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
        ._printChanges()
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

// Placeholder views - we'll implement these in subsequent steps
struct GenerateContentView: View {
    let store: StoreOf<GenerateFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("Generate Content View")
                    .font(.title2)
                Text("This will be implemented in the next step")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

struct HistoryContentView: View {
    let store: StoreOf<HistoryFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("History Content View")
                    .font(.title2)
                Text("Translation history and favorites")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

struct SettingsContentView: View {
    let store: StoreOf<SettingsFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("Settings Content View")
                    .font(.title2)
                Text("Font, theme, and configuration settings")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}