import Foundation
import SwiftUI

// MARK: - Modern Font Configuration System
// Modern Swift features: protocol-oriented, type-safe, Swift Concurrency

protocol FontConfigProtocol {
    var displayName: String { get }
    var isCodeFont: Bool { get }
    var isMonospace: Bool { get }
}

protocol FontSizeProtocol {
    var displayName: String { get }
    var pointSize: CGFloat { get }
    var lineHeight: CGFloat { get }
}

protocol ThemeProtocol {
    var displayName: String { get }
    var colorScheme: ColorScheme { get }
}

// MARK: - Font Family
enum ModernFontFamily: String, CaseIterable, Hashable, Codable, FontConfigProtocol {
    case system = "SF Pro"
    case avenir = "Avenir"
    case helvetica = "Helvetica Neue"
    case menlo = "Menlo"
    case monaco = "Monaco"
    case sfMono = "SF Mono"

    var displayName: String {
        switch self {
        case .system: return "System Font"
        case .avenir: return "Avenir"
        case .helvetica: return "Helvetica Neue"
        case .menlo: return "Menlo (Code)"
        case .monaco: return "Monaco (Code)"
        case .sfMono: return "SF Mono (Code)"
        }
    }

    var isCodeFont: Bool {
        return self == .menlo || self == .monaco || self == .sfMono
    }

    var isMonospace: Bool {
        return isCodeFont
    }

    var nativeFont: NSFont {
        if self == .system {
            return NSFont.systemFont(ofSize: 16, weight: .medium)
        } else {
            return NSFont(name: self.rawValue, size: 16) ??
                   NSFont.systemFont(ofSize: 16, weight: .medium)
        }
    }
}

// MARK: - Font Size
enum ModernFontSize: Int, CaseIterable, Hashable, Codable, FontSizeProtocol {
    case small = 16
    case medium = 20
    case large = 24
    case extraLarge = 32
    case huge = 48

    var displayName: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        case .extraLarge: return "Extra Large"
        case .huge: return "Huge"
        }
    }

    var pointSize: CGFloat {
        return CGFloat(rawValue)
    }

    var lineHeight: CGFloat {
        return pointSize * 1.4
    }

    var letterSpacing: CGFloat {
        switch self {
        case .small, .medium: return 0.0
        case .large: return 0.2
        case .extraLarge: return 0.4
        case .huge: return 0.6
        }
    }
}

// MARK: - Modern Theme
enum ModernTheme: String, CaseIterable, Hashable, Codable, ThemeProtocol {
    case light = "light"
    case dark = "dark"
    case gradient = "gradient"
    case modern = "modern"
    case minimalist = "minimalist"

    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .gradient: return "Gradient"
        case .modern: return "Modern"
        case .minimalist: return "Minimalist"
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .gradient: return .light
        case .modern: return .dark
        case .minimalist: return .light
        }
    }

    var primaryColor: Color {
        switch self {
        case .light: return .white
        case .dark: return Color(.controlBackgroundColor)
        case .gradient: return Color(.controlBackgroundColor)
        case .modern: return Color(.windowBackgroundColor)
        case .minimalist: return Color.white
        }
    }

    var textColor: Color {
        switch self {
        case .light: return .primary
        case .dark: return .primary
        case .gradient: return Color(.controlTextColor)
        case .modern: return Color(.controlTextColor)
        case .minimalist: return .black
        }
    }

    var accentColor: Color {
        switch self {
        case .light: return .blue
        case .dark: return .accentColor
        case .gradient: return Color(.controlAccentColor)
        case .modern: return Color(.controlAccentColor)
        case .minimalist: return .gray
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .light: return 8
        case .dark: return 12
        case .gradient: return 16
        case .modern: return 20
        case .minimalist: return 4
        }
    }
}


// MARK: - Modern Font Configuration Manager
@MainActor
class ModernFontConfigurationManager: ObservableObject, FontConfigManaging {
    static let shared = ModernFontConfigurationManager()

    @Published var currentConfig: ExportConfiguration = .default
    @Published var recentConfigs: [ExportConfiguration] = []
    @Published var favoriteConfigs: [ExportConfiguration] = []

    private let storageKey = "ModernFontConfiguration"
    private let maxRecentConfigs = 10
    private let maxFavoriteConfigs = 20

    private init() {
        loadConfiguration()
    }

    // MARK: - Configuration Management
    func updateConfiguration(_ config: ExportConfiguration) {
        currentConfig = config
        addToRecent(config)
        saveConfiguration()
    }

    func resetToDefault() {
        updateConfiguration(.default)
    }

    func applyPreset(_ preset: ExportConfigurationPreset) {
        let config: ExportConfiguration
        switch preset {
        case .`default`:
            config = .default
        case .codeFocused:
            config = .codeFocused
        case .presentation:
            config = .presentation
        case .minimal:
            config = .minimal
        }
        updateConfiguration(config)
    }

    // MARK: - Recent Configurations
    private func addToRecent(_ config: ExportConfiguration) {
        // Remove if already exists
        recentConfigs.removeAll { $0 == config }

        // Add to beginning
        recentConfigs.insert(config, at: 0)

        // Limit to max count
        if recentConfigs.count > maxRecentConfigs {
            recentConfigs = Array(recentConfigs.prefix(maxRecentConfigs))
        }
    }

    func clearRecentConfigs() {
        recentConfigs.removeAll()
        saveConfiguration()
    }

    // MARK: - Favorite Configurations
    func addToFavorites(_ config: ExportConfiguration) {
        guard !favoriteConfigs.contains(config) else { return }

        favoriteConfigs.append(config)
        saveConfiguration()
    }

    func removeFromFavorites(_ config: ExportConfiguration) {
        favoriteConfigs.removeAll { $0 == config }
        saveConfiguration()
    }

    func isFavorite(_ config: ExportConfiguration) -> Bool {
        return favoriteConfigs.contains(config)
    }

    // MARK: - Persistence
    private func saveConfiguration() {
        let configData = ConfigurationData(
            currentConfig: currentConfig,
            recentConfigs: recentConfigs,
            favoriteConfigs: favoriteConfigs
        )

        do {
            let encoded = try JSONEncoder().encode(configData)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Failed to save configuration: \(error)")
        }
    }

    private func loadConfiguration() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }

        do {
            let configData = try JSONDecoder().decode(ConfigurationData.self, from: data)
            currentConfig = configData.currentConfig
            recentConfigs = configData.recentConfigs
            favoriteConfigs = configData.favoriteConfigs
        } catch {
            print("Failed to load configuration: \(error)")
        }
    }

    // MARK: - Validation
    func validateConfiguration(_ config: ExportConfiguration) -> [ConfigurationError] {
        var errors: [ConfigurationError] = []

        if config.padding < 0 || config.padding > 200 {
            errors.append(.invalidPadding(config.padding))
        }

        if config.maxWidth < 100 || config.maxWidth > 2000 {
            errors.append(.invalidMaxWidth(config.maxWidth))
        }

        if config.lineHeight < 0.5 || config.lineHeight > 3.0 {
            errors.append(.invalidLineHeight(config.lineHeight))
        }

        return errors
    }
}

// MARK: - Supporting Types
enum ExportConfigurationPreset: String, CaseIterable {
    case `default` = "default"
    case codeFocused = "codeFocused"
    case presentation = "presentation"
    case minimal = "minimal"

    var displayName: String {
        switch self {
        case .default: return "Default"
        case .codeFocused: return "Code Focused"
        case .presentation: return "Presentation"
        case .minimal: return "Minimal"
        }
    }

    var description: String {
        switch self {
        case .default: return "Balanced settings for general use"
        case .codeFocused: return "Optimized for code and technical content"
        case .presentation: return "Perfect for presentations and slides"
        case .minimal: return "Clean and minimal design"
        }
    }
}


// MARK: - Data Structures for Persistence
private struct ConfigurationData: Codable {
    let currentConfig: ExportConfiguration
    let recentConfigs: [ExportConfiguration]
    let favoriteConfigs: [ExportConfiguration]
}

// MARK: - SwiftUI Integration
@MainActor
struct FontConfigurationView: View {
    @StateObject private var configManager = ModernFontConfigurationManager.shared

    var body: some View {
        Form {
            Section("Font") {
                Picker("Font Family", selection: Binding(
                    get: { configManager.currentConfig.fontFamily },
                    set: { configManager.updateConfiguration(
                        configManager.currentConfig.with(fontFamily: $0)
                    )}
                )) {
                    ForEach(ModernFontFamily.allCases, id: \.self) { family in
                        Text(family.displayName).tag(family)
                    }
                }

                Picker("Font Size", selection: Binding(
                    get: { configManager.currentConfig.fontSize },
                    set: { configManager.updateConfiguration(
                        configManager.currentConfig.with(fontSize: $0)
                    )}
                )) {
                    ForEach(ModernFontSize.allCases, id: \.self) { size in
                        Text(size.displayName).tag(size)
                    }
                }
            }

            Section("Appearance") {
                Picker("Theme", selection: Binding(
                    get: { configManager.currentConfig.theme },
                    set: { configManager.updateConfiguration(
                        configManager.currentConfig.with(theme: $0)
                    )}
                )) {
                    ForEach(ModernTheme.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
            }

            Section("Layout") {
                Slider(value: Binding(
                    get: { configManager.currentConfig.padding },
                    set: { configManager.updateConfiguration(
                        configManager.currentConfig.with(padding: $0)
                    )}
                ), in: 10...100) {
                    Text("Padding: \(Int(configManager.currentConfig.padding))")
                }

                Slider(value: Binding(
                    get: { configManager.currentConfig.maxWidth },
                    set: { configManager.updateConfiguration(
                        configManager.currentConfig.with(maxWidth: $0)
                    )}
                ), in: 200...1200) {
                    Text("Max Width: \(Int(configManager.currentConfig.maxWidth))")
                }
            }

            Section("Watermark") {
                TextField("Watermark text", text: Binding(
                    get: { configManager.currentConfig.watermark ?? "" },
                    set: { configManager.updateConfiguration(
                        configManager.currentConfig.with(watermark: $0.isEmpty ? nil : $0)
                    )}
                ))
            }
        }
    }
}

