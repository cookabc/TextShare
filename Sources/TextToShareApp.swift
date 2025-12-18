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
                .background(EffectView(material: .sidebar, blendingMode: .behindWindow).ignoresSafeArea())
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Preferences…") {
                    NSApp.sendAction(Selector(("showPreferences:")), to: nil, from: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        .defaultSize(width: 900, height: 650)
    }
}

// Helper for window background material
struct EffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
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

// SidebarView moved to Sources/Views/SidebarView.swift

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